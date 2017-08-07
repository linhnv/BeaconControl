$ ->
  $customerId = undefined
  $logoInput = undefined
  bindAddress = undefined
  bindContactForm = undefined
  bindEditForm = undefined
  createRow = undefined
  customerContainer = undefined
  customerURL = undefined
  customers = undefined
  fetchTable = undefined
  fetchURL = undefined
  form = undefined
  hideError = undefined
  showError = undefined
  validatePrecense = undefined
  $customerId = undefined
  $logoInput = undefined
  createRow = undefined
  customerContainer = undefined
  fetchTable = undefined
  fetchURL = undefined
  form = undefined
  hideError = undefined
  showError = undefined
  validateCustomer = undefined
  validatePrecense = undefined

  if $('#customer').length and $('.contact').length
    bindEditForm = (customer) ->
      $('input[name="id"]').val customer.id
      $('input[name="email"]').val customer.email
      $('input[name="customer_name"]').val customer.contact.name
      $('#applications').selectpicker 'val', customer.customers_applications.map((e) ->
        e.applications_id
      )
      bindContactForm customer.contact
      bindAddress customer.address
      return

    bindContactForm = (contact) ->
      $('input[name="contact_name"]').val contact.name
      $('input[name="position"]').val contact.position
      $('input[name="phone_number"]').val contact.phone_number
      return

    bindAddress = (address) ->
      $('input[name="zip"]').val address.zip
      $('input[name="city"]').val address.city
      $('input[name="street"]').val address.street
      return

    $customerId = undefined
    $logoInput = undefined
    customerURL = undefined
    form = undefined
    hideError = undefined
    showError = undefined
    validateCustomer = undefined
    validatePrecense = undefined

    createRow = (customer) ->
      '<tr>' + '<td>' + customer.contact.name + '</td>' + '<td>' + customer.contact.phone_number + '</td>' + '<td>' + customer.email + '</td>' + '<td>' + customer.username + '</td>' + '<td><a class="edit" href="#" data-id="' + customer.id + '">Detail</a></td>' + '<td><a class="reset-password" href="#" data-id="' + customer.id + '">Reset Password</a></td>' + '<td><a class="delete" href="#" data-id="' + customer.id + '">Lochen</a></td>' + '</tr>'

    fetchTable = () ->
      $.get fetchURL, (data) ->
        window.customers = data.customers
        window.customers[0][1] = data.customers[0][1].map((e) ->
          JSON.parse e
        )
        customerContainer.html data.customers[0][1].reduce(((total, customer) ->
          total + createRow(customer)
        ), '')
        return
      return

    form = $('form#customer')
    $customerId = $('#customer_id')
    customerURL = '/customers/'
    $logoInput = $('.logo input')

    showError = (errorMessage, $input) ->
      $input.siblings('.form-control-feedback').html errorMessage
      $input.closest('.form-group').addClass 'has-error'
      $input.focus()
      return

    hideError = ($input) ->
      $input.siblings('.form-control-feedback').html ''
      $input.closest('.form-group').removeClass 'has-error'
      return

    validatePrecense = ($input, fieldName) ->
      if $input.val() != ''
        hideError $input
        true
      else
        showError 'Please enter ' + fieldName, $input
        false

    validateCustomer = (id) ->
      $customerName = undefined
      $customerName = $('input[name="customer_name"]')
      validatePrecense($customerName, 'customer name')

    $('.logo input').ezdz
      text: 'Drop images here or click to upload'
      preview: true
      validators:
        maxWidth: 1024
        maxHeight: 768
        maxSize: 1000000
      classes:
        main: 'ezdz-dropzone'
        enter: 'ezdz-enter'
        reject: 'ezdz-reject'
        accept: 'ezdz-accept'
        focus: 'ezdz-focus'
      accept: (filename) ->
        $logoInput.closest('.form-group').removeClass 'has-error'
        return
      reject: (filename) ->
        $logoInput.closest('.form-group').addClass 'has-error'
        return
    $('#applications').selectpicker()
    $.ajaxSetup headers: 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    form.submit ->
      formData = undefined
      customerId = undefined

      formData = new FormData($(this)[0])
      customerId = $customerId.val()

      if customerId != ''
        url = customerURL + customerId
        formData.append('_method', 'put')
      else
        url = customerURL
      if validateCustomer(customerId)
        $.ajax
          url: url
          type: 'POST'
          data: formData
          async: false
          success: (data) ->
            $('#cancel').click()
            fetchTable 1
            return
          error: (errors) ->
            errors.responseJSON.customers[0][1].forEach (e) ->
              showError e + 'has already been taken', $('#' + e)
              return
            return
          cache: false
          contentType: false
          processData: false
      false
    fetchURL = '/customers.json'
    customerContainer = $('tbody')
    $('table').on 'click', '.edit', (e) ->
      customer = undefined
      id = undefined
      id = $(this).data('id')
      customer = window.customers[0][1].find((e) ->
        e.id == id
      )
      bindEditForm customer
      return
    $('table').on 'click', '.delete', (e) ->
      r = confirm("Are you sure to delete this customer?");
      if r == true
        $.ajax
          type: 'POST'
          url: customerURL + $(this).data('id')
          dataType: 'json'
          data: '_method': 'delete'
          complete: ->
            fetchTable 1
            $('#cancel').click()
            return
      e.preventDefault()
      return
    $('table').on 'click', '.reset-password', (e) ->
      $('input[name="id"]').val customer.id
      r = confirm("Are you sure to reset password this customer?");
      if r == true
        $.ajax
          type: 'POST'
          url: customerURL + $(this).data('id') + '/update_password'
          dataType: 'json'
          data: '_method': 'put'
          complete: ->
            return

      e.preventDefault()
      return

    fetchTable 1
    $('#cancel').click (e) ->
      $('.contact').show()
      $('.address').show()
      $('.applications').show()
      $('.contact-label').show()
      $('.customer_name').show()
      $('.logo').show()

      form[0].reset()
      $('#applications').selectpicker 'val', []
      e.preventDefault()
  return
return
