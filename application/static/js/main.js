/**
 * Created by ricardo on 15/06/16.
 */

$(document).ready(function () {
    $('.message .close')
        .on('click', function () {
            $(this)
                .closest('.message')
                .transition('fade')
            ;
        })
    ;
    $('#user-dropdown').dropdown({
            on: 'hover',
            action: 'nothing'
        })
    ;
});