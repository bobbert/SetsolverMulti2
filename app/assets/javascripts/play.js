$(document).ready(function() {

  var dispatcher = null;
  var gameChannel = null;
  var gameId = parseInt($('#setboard').data('gameid'));

  // only execute code if user is actively playing a Set game with an
  // identifiable game ID
  if (!isNaN(gameId)) {

    $('#setboard input:checkbox').hide();

    $('#setboard').on('click', 'ul.setboard-row li img', function() {
      selectSetCard($(this).parent());
    });

    initializeWebSocketAndGameChannel();

    function initializeWebSocketAndGameChannel() {
      console.log("Establishing WebSocketRails connection.");
      dispatcher = new WebSocketRails('localhost:3000/websocket');
      dispatcher.on_open = function() {
        gameChannel = dispatcher.subscribe("setgame_" + gameId);
        // gameChannel.bind('update_game', function(data) {
        //   console.log('WebSocket return data:', data);
        //   processResults(data);
        // });
        dispatcher.bind('game_message', function(data) {
          if (data.error) {
            alert("Error: " + data.error);
          }
        });
        dispatcher.bind('update_game', function(data) {
          console.log('WebSocket return data:', data);
          processResults(data);
        });

      };
    }

    function selectSetCard(cell) {
      var chk = cell.find('input:checkbox');
      if (chk.length > 0) {
        was_checked = chk.prop('checked');
        chk.prop('checked', !was_checked);
        was_checked ? cell.removeClass('selected') : cell.addClass('selected');
        if ($('#setboard li.selected input:checkbox:checked').length === 3 ) {
          sendSetRequestWS();
        }
      }
    }

    function sendSetRequestWS() {
      var selected_cards = getSelectedCardIndices();
      console.log("Playing cards: ", {game_id: gameId, cards: selected_cards});
      dispatcher.trigger('play_cards', {game_id: gameId, cards: selected_cards});
    }

    function sendSetRequest() {
      var action_and_query_params = "play_cards?cards=" + getSelectedCardIndices().join(",");
      var action_url = window.location.pathname.replace(/play$/, action_and_query_params);
      $.ajax({
        type: "PUT",
        url: action_url
      }).done(function(data) {
        processResults(data);
      }).fail(function(jqXHR, textStatus) {
        $('#notice').hide();
        $('#error').text(textStatus).show();
      });
    }

    function processResults(data) {
      console.log("Return value = " + JSON.stringify(data));
      if (data.state === 'good_move') {
        $('#notice').hide();
        $('#error').hide();
        updateBoard(data.field);
        updateGameActivity(data);
      }
      else if (data.state === 'bad_move') {
        $('#notice').text(data.error).show();
        $('#error').hide();
        unselectAllCards();
      }
      else if (data.state === 'finished') {
        alert("Game finished.");
      }
    }

    function updateBoard(board) {
      $.each(board, function(cardIndex, cardData) {
        var $cardImg = $('#c_card' + cardIndex).find('img');
        if ($cardImg.length > 0) {
          $cardImg.attr('src', cardData.image).attr('alt', cardData.name);
        }
      });
      unselectAllCards();
    }

    function updateGameActivity(data) {
      $('span#remaining').text(number_noun_desc(data.cards_remaining, "card"));
      $('span#num_sets').text(number_noun_desc(data.set_count, "set"));
      $.each(data.scores, function(indx, scoreData) {
        var $scoreEl = $('#gamescore_' + scoreData.id);
        $scoreEl.text(scoreData.score);
      });
      updateActivityLog(data.set);
    }

    function unselectAllCards() {
      $('#setboard li.setboard-cell').each(function(index, cell) {
        $(cell).removeClass('selected');
        $(cell).find('input:checkbox').prop('checked', false);
      });
    }

    function getSelectedCardIndices() {
      return $.map($('li.selected input:checkbox:checked'), function(checkEl) {
        return parseInt($(checkEl).attr('name').replace(/^card/, ""));
      });
    }

    function resetBoard() {
      $('#submitbar').hide();
      $('input:checkbox:checked').each(function() {
        selectSetCard($(this).parent());
      });
    }

    // updates activity log: remove set at end of list, and add newly
    function updateActivityLog(setData) {
      if ( $('ul#set_records li').length == 4 ) {
        $('ul#set_records li:last').remove();
      }
      var $activityEntryEl = cloneNewActivityNode();
      $activityEntryEl.find('h5').text(setData.created_at);
      var images = $activityEntryEl.find('img');
      $.each(setData.cards, function(cardIndex, cardData) {
        $(images[cardIndex]).attr('src', cardData.image).attr('alt', cardData.name);
      });
      $activityEntryEl.insertBefore($('ul#set_records li:first')).show();  // RWP: does not account for first element
      $('ul#set_records li.dummy-first-node').remove();
      return true;
    }

    function cloneNewActivityNode() {
      return $('ul#set_records li:first').clone().removeClass('dummy-first-node').hide();
    }

    function number_noun_desc(number, singularNoun) {
      return number.toString() + " " + singularNoun + ((number === 1) ? "" : "s");
    }

  }

});
