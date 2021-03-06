###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

class CouponAttachment < ActiveRecord::Base
  belongs_to :coupon

  validates :type,
    presence: true,
    length: { maximum: 255 },
    inclusion: { in: %w(audio video) }

  mount_uploader :file, BaseUploader

  def self.inheritance_column
    "kind"
  end

  def remove_file=(val)
    file_will_change! if val == 'true'
    super
  end

  def filename
    File.basename(file.path)
  end

  def thumb_url
    "/images/preview/#{type}.png"
  end

  delegate :url, to: :file, allow_blank: true
end
