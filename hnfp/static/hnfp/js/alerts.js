$(document).ready(function() {
  $('#new-alert-btn').click(function() {
    alerts.initNew();
  });
  if (typeof recent_alerts !== 'undefined') {
    alerts.recentAlerts(recent_alerts);
  }
  function getCookie(name) {
      var cookieValue = null;
      if (document.cookie && document.cookie !== '') {
          var cookies = document.cookie.split(';');
          for (var i = 0; i < cookies.length; i++) {
              var cookie = jQuery.trim(cookies[i]);
              // Does this cookie string begin with the name we want?
              if (cookie.substring(0, name.length + 1) === (name + '=')) {
                  cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                  break;
              }
          }
      }
      return cookieValue;
  }
  var csrftoken = getCookie('csrftoken');
  function csrfSafeMethod(method) {
      // these HTTP methods do not require CSRF protection
      return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
  }
  $.ajaxSetup({
      beforeSend: function(xhr, settings) {
          if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
              xhr.setRequestHeader("X-CSRFToken", csrftoken);
          }
      }
  });
});

$newAlertsWrap = $('#new-alert-wrapper');
$recentAlertsWrap = $('.recent-alerts');
$alertForm = $( '#alert-form' );

var alerts = {
  recentAlerts: function(alerts) {
    for (let alert of alerts) {
      if (alert.alert_comment == null) {
        alert.alert_comment = '';
      }
      $recentAlertsWrap.append(`<div class="row">
        <div class="col s10 offset-s1">
          <article id="alert_${alert.alert_id}">
            <div class="triangle">${alert.alert_id}</div>
            <h3>${alert.alert_type}</h3>
            <p><em>posted by ${alert.alert_username}<br />${alert.alert_date} ${alert.alert_time}</em></p>
            <p>${alert.alert_comment}</p>
            <p><img src="${alert.alert_photo}" /></p>
          </article>
        </div>
      </div>`);
    }
  },
  scrollToAlert: function(alert_id) {
    var alert_div ='alert_' + alert_id;
    alert_div = alert_div.toString();
    let $mapPanel = $('#map-panel'),
        $alert_div = $('#map-panel').find('#' + alert_div);
    if ($alert_div.length > 0) {
      let pos = $alert_div.position();
      if (window.innerWidth > 1024) {
        $mapPanel.animate({
          scrollTop: pos.top
        }, {
          duration: "slow"
        })
      } else {
        $mapPanel.animate({
          scrollTop: pos.top,
          opacity: 1
        }, {
          duration: "slow"
        })
      }
    }
  },
  stepTwo: function() {
    $('#steptwo').removeClass('visible');
    $('#stepthree').addClass('visible');
    $('#loc-correct').click(function() {
      alerts.setInputLoc();
      let hide = '#stepthree';
      alerts.showStepFour(hide);
    });
  },
  showStepFour: function(step) {
    $(step).removeClass('visible');
    $('#stepfour').addClass('visible');
  },
  backStepThree: function() {
    var loc = getLocationPoint();
    $('#stepchangeloc').addClass('visible');
    $('#stepfour').removeClass('visible');
    $('#loc-change').click(function() {
      alerts.setInputLoc();
      let hide = '#stepchangeloc';
      alerts.showStepFour(hide);
    });
  },
  locOkay: function() {
    let hide = '#stepchangeloc';
    alerts.showStepFour(hide);
  },
  setInputLoc: function() {
    $('#alert_location').val(getLocationPoint());
  },
  close: function() {
    $newAlertsWrap.find('form').html('');
    $newAlertsWrap.removeClass('visible');
  },
  showSpinner: function() {
    $('.preloader-wrapper').addClass('active');
  },
  hideSpinner: function() {
    $('.preloader-wrapper').removeClass('active');
  },
  initNew: function() {
    $newAlertsWrap
    $newAlertsWrap.toggleClass('visible');
    if (!$newAlertsWrap.hasClass('visible')) {
      $alertForm.html('');
      return;
    }
    return $.ajax({
        url: '/alert/new/',
        success: function(data) {
            $alertForm.html(data);
        },
        error: function (result) {
            //debugger;
        }
    }).done(function() {
      $('.timepicker').pickatime({
        default: 'now', // Set default time: 'now', '1:30AM', '16:30'
        fromnow: 0,       // set default time to * milliseconds from now (using with default = 'now')
        donetext: 'Okay', // text for done-button
        cleartext: 'Clear', // text for clear-button
        autoclose: false, // automatic close timepicker
        aftershow: function(){} //Function for after opening timepicker
      });
      $('.datepicker').pickadate({
        selectMonths: true, // Creates a dropdown to control month
        selectYears: 5,
        today: 'Today',
        clear: 'Clear',
        close: 'Ok',
        closeOnSelect: false // Close upon selecting a date,
      });
      $alertForm.submit(function(e) {
        e.preventDefault();
        alerts.create(e.target);
      });
      $('#steptwo').addClass('visible');
      showLocation();
      $('#use-my-location').click(function() {
        alertMap.alertAtMyLocation();
        alerts.stepTwo();
      });
      $('#choose-from-map').click(function() {
        alertMap.drawLocation();
        alerts.stepTwo();
      });
      /* $('#alert_photo').change(function(e) {
        alerts.photo(e.target.files[0]);
      }); */
    });
  },
  photo: function(p) {
    let photoForm;
    if (typeof(p) !== 'undefined') {
      photoForm = new FormData();
      if (p.size < 1048576) {
        photoForm.append('alert_photo', p, p.name);
      }
    }
    return photoForm;
  },
  create: function(form) {
    $form = $(form).serialize();
    return $.ajax({
      type: 'POST',
      url: '/alert/create/',
      data: $form,
      success: function(data) {
        let newData = data.length - 1;
        addAlertsToMap(data[newData]);
        hideLocation();
        alerts.close();
        $alertForm.html('');
        Materialize.toast('Alert Report Submission Successful', 4000);
      },
      error: function (error) {
        $alertForm.prepend(error);
        hideLocation();
        Materialize.toast('Alert Report Submission Failed. Please Ensure You Have Internet Access & Try Again.', 6000);
      }
    });
  }
};
