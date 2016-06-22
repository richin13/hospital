/**
 * Created by ricardo on 22/06/16.
 */
 $(document).ready(function () {
     var $form = $('#update-profile-form');

     $('#name').val($form.data('default-name'));
     $('#last_name').val($form.data('default-last-name'));
     $('#genre').val($form.data('default-gender')).change();
     $('#email').val($form.data('default-email'));
     $('#username').val($form.data('default-username'));
 });