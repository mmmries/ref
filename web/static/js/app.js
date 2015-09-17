// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

import {Socket} from "deps/phoenix/web/static/js/phoenix"

window.TicTacToe = function(game_id, just_watching, ai) {
  let socket = new Socket("/socket")
  socket.connect()
  let token = ((Math.random() * 10000) + "")
  let channel = socket.channel("tictactoe:"+game_id, {token: token, name: "anonymous", just_watching: just_watching, ai: ai})
  let log_div = $('#log')
  let log = function(message) {
    let log_entry = document.createElement("div")
    log_entry.textContent = message
    log_div.prepend(log_entry)
  };
  let stat = $("#status")
  let role = null;
  let render_board = function(board) {
    for( var i in board ) {
      let c = board[i] ? board[i] : "-"
      $('[data-square='+i+']').text(c)
    }
  };

  channel.join().receive("ok",
    msg => {
      if(msg.role) {
        log("Joined the game! You are "+msg.role);
      }
    }
  ).receive("error",
    msg => {
      log("Failed to join the game: "+msg.message)
      stat.text("Could not join game: "+msg.message)
    }
  )

  channel.on("state",
    msg => {
      render_board(msg.board)
      if( msg.whose_turn == role ) {
        stat.text("Your turn, make your move")
      } else {
        stat.text("Waiting for other player...")
      }
    }
  )

  channel.on("game_over",
    msg => {
      render_board(msg.board)
      log("Game Over!")
      if(msg.winner == "tie") {
        log("The game is a tie!")
        stat.text("The game is a tie!")
      } else {
        log(msg.winner+" is the winner!")
        stat.text(msg.winner+" is the winner!")
      }
      if(!just_watching){
        channel.leave()
        socket.disconnect()
      }
    }
  )

  if( !just_watching ) {
    $('.tic-tac-toe.board').click( function(evt) {
      let square = $(evt.target).data('square')
      console.log('trying to take square '+square)
      channel.push('move', {token: token, square: square}).receive("error",
        msg => {
          log(msg.message)
          stat.text(msg.message)
        }
      )
    });
  }
}
