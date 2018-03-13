###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

class Admin < ActiveRecord::Base
  extend UuidField
  include HasCorrelationId
  include Searchable

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  if AppConfig.registerable
    devise :database_authenticatable, :registerable,
           :rememberable, :trackable, :validatable,
           :confirmable, :recoverable, :password_archivable
  else
    devise :database_authenticatable, :omniauthable,
           :rememberable, :trackable, :validatable,
           :confirmable, :recoverable, :password_archivable
  end

  enum role: [:admin, :beacon_manager]

  validates :role,
    presence: true,
    inclusion: { in: Admin.roles }

  belongs_to :account
  has_many :zones,   foreign_key: :manager_id, dependent: :nullify
  has_many :beacons, foreign_key: :manager_id, dependent: :nullify

  has_many :access_tokens, -> { where(scopes: 'admin') },
    class_name:  'Doorkeeper::AccessToken',
    foreign_key: 'resource_owner_id',
    dependent:   :destroy

  delegate :applications, :test_application, :triggers, :activities, to: :account

  #
  # Includes UuidField module functionality.
  #
  uuid_field :default_beacon_uuid

  scope :beacon_managers, -> { where(role: roles[:beacon_manager]) }

  scope :sorted, -> (column, direction) do
    sorted_column = %w(admins.email admins.role).include?(column) ?
                      column :
                      'admins.email'
    direction = %w[asc desc].include?(direction) ?
                  direction :
                  'asc'
    order("#{sorted_column} #{direction}")
  end

  scope :with_email, ->(email) { where('email LIKE ?', "%#{email}%") }

  after_create do
    confirm! if !confirmed?
  end

  validates :password, confirmation: true, on: :update, if: -> { password.present? }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |admin|
      admin.email = auth.info.email
      admin.password = Devise.friendly_token[0,20]
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      admin.skip_confirmation!
    end
  end

  def account_managers
    account.admins.beacon_managers
  end

  def after_database_authentication
    update_correlation_id_from_current_thread
    save
  end

  protected

  def password_required?
    persisted? && encrypted_password.blank?
  end
end
