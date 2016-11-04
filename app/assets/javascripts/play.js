$(document).ready(function() {

  $(':checkbox').hide();

  $('#setboard').on('click', 'ul.setboard-row li img', function() {
    selectSetCard($(this).parent());
  });

  function selectSetCard(cell) {
    var chk = cell.find('input:checkbox');
    if ((chk.length > 0) && !(isSubmitting())) {
      was_checked = chk.prop('checked');
      chk.prop('checked', !was_checked);
      was_checked ? cell.removeClass('selected') : cell.addClass('selected');
      if ($('#setboard li.selected input:checkbox:checked').length === 3 ) {
        sendSetRequest();
      }
    }
  }

  function sendSetRequest() {
    var action_and_query_params = "play_cards?cards=" + getSelectedCardIndices().join(",");
    var action_url = window.location.pathname.replace(/play$/, action_and_query_params);
    $.ajax({
      type: "PUT",
      url: action_url
    }).done(function(data) {
      console.log("Return value = " + JSON.stringify(data));
      if (data.state === 'good_move') {
        $('#notice').hide();
        $('#error').hide();
        updateBoard(data.field);
      }
      else if (data.state === 'bad_move') {
        $('#notice').text(data.error).show();
        $('#error').hide();
        unselectAllCards();
      }
    }).fail(function(jqXHR, textStatus) {
      $('#notice').hide();
      $('#error').text(textStatus).show();
    });
  }

  function updateBoard(board) {
    for (var cardIndex = 0; cardIndex < board.length; cardIndex++) {
      var cardData = board[cardIndex];
      var $cardImg = $('#c_card' + cardIndex).find('img');
      if ($cardImg.length > 0) {
        $cardImg.attr('src', cardData.image).attr('alt', cardData.name);
      }
    }
    unselectAllCards();
  }

  function unselectAllCards() {
    $('#setboard li.setboard-cell').each(function(index, cell) {
      $(cell).removeClass('selected');
      $(cell).find('input:checkbox').prop('checked', false);
    });
  }

  function getSelectedCardIndices() {
    return $.map($('li.selected input:checkbox:checked'), function(checkEl) {
      return $(checkEl).attr('name').replace(/^card/, "");
    });
  }

  function resetBoard() {
    $('#submitbar').hide();
    $('input:checkbox:checked').each(function() {
      selectSetCard($(this).parent());
    });
  }

  // saving image into DOM then loading previewer
  function parseGameXml(xml) {
    var num_cards = $(xml).find("field_size").text();
    var indx = 0;

    if (parseErrorsIfFound(xml)) {
      return false;
    }
    if ($(xml).find("status").text() == 'finished') {
      return submitCompletedForm();
    }

    // calculate difference between number of XML cards and number of cards in browser
    var new_field_size_diff = parseInt(num_cards) - $('#setboard ul.setboard-row li').length;

    // call routine to add or remove cards, if new gamefield contains a different number of cards
    while (new_field_size_diff > 0) {
      addCells();
      new_field_size_diff = new_field_size_diff - 3;
    }
    while (new_field_size_diff < 0) {
      removeCells();
      new_field_size_diff = new_field_size_diff + 3;
    }

    $('#remaining, #num_sets').each(function() {
      $(this).text( $(xml).find(this.id).text() );
    });

    $('#score_listing li span').each(function() {
      $(this).text( $(xml).find('points').text() );
    });

    var img_list = $('#setboard ul.setboard-row li img');

    // find picture and append contents to image viewer
    $(xml).find('card').each(function() {
      //var field_position = $(this).find("field_id").text();
      var set_card_name = $(this).find("name").text();
      var set_card_imgpath = $(this).find("image_path").text();

      // run previewer-loading code after image loads
      img_list.eq(indx).attr('title', set_card_name).attr('src', set_card_imgpath);
      indx += 1;

    });

    // update activity log on right if new set is found
    if ( $(xml).find('found_set') ) {
      updateActivityLog( $(xml).find('found_set') );
    }
    return true;
  }

  // parse flash messages (notices or errors) found in XML and return True if present
  function parseErrorsIfFound(xml) {
    var errors_found = false;
    $('#notice, #error').each(function() {
      msg_txt = $(xml).find(this.id).text();
      $(this).text( msg_txt );
      if (msg_txt.length > 0) {
	errors_found = true;
        $(this).show();
      } else {
        $(this).hide();
      }
    });
    return errors_found;
  }

  // adds new column to the right of Set gamefield
  function addCells() {
    //var col_len = $('#setboard ul.setboard-row li:first').css('width');
    var col_len = 84;  // RWP TEMP
    var num_cards = $('#setboard ul.setboard-row li').length;
    $('#setboard_panel').css('width',((num_cards * col_len / 3) + col_len) + 'px');
    $('#setboard ul.setboard-row').each(function() {
      var new_item = $(this).find('li').last().clone().attr('id','c_card'+num_cards);
      new_item.find('input').attr('id','card'+num_cards).attr('name','card'+num_cards);
      new_item.appendTo($(this));
      num_cards += 1;
    });
  }

  // removes rightmost column of Set cards
  removeCells = function() {
    //var col_len = $('#setboard ul.setboard-row li:first').css('width');
    var col_len = 84;  // RWP TEMP
    var num_cards = $('#setboard ul.setboard-row li').length;
    $('#setboard_panel').css('width',((num_cards * col_len / 3) - col_len) + 'px');
    $('#setboard ul.setboard-row li:last-child').remove();
  }

  // updates activity log: remove set at end of list, and add newly
  updateActivityLog = function(setcard_xml) {
    if ( $('ul#set_records li').length == 4 ) {
      $('ul#set_records li:last').remove();
    }
    var new_col = cloneNewActivityNode();
    new_col.find('h5').text( $(setcard_xml).find('created_at').text() );
    new_col.find('span.setlisting-name').text( $(setcard_xml).find('found_by').text() );
    new_col.find('span.setlisting-time').text( $(setcard_xml).find('seconds_to_find').text() );
    var set_images = new_col.find('p.setlisting img');
    var indx = 0;  // used to mimic Ruby each_with_index behavior

    $(setcard_xml).find('setcard').each(function() {
      var set_card_name = $(this).find('name').text();
      var set_card_imgpath = $(this).find('image_path').text();
      set_images.eq(indx).attr('title', set_card_name).attr('src', set_card_imgpath);
      indx += 1;
    });
    new_col.insertBefore($('ul#set_records li:first')).show();  // RWP: does not account for first element
    $('ul#set_records li.dummy-first-node').remove();
    return true;
  }

  cloneNewActivityNode = function() {
    return $('ul#set_records li:first').clone().removeClass('dummy-first-node').hide();
  }

  isSubmitting = function() {
    return ($('#submitbar:visible').length > 0);
  }

  // Set game is complete - make call to archive
  submitCompletedForm = function() {
    $('input[name=commit]').trigger('click');
  }

});
