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

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import {Socket} from "deps/phoenix/web/static/js/phoenix"
let socket = new Socket("/socket")
socket.connect()
window.chan = socket.channel("tictactoe:abc123", {token: "abc123", name: "Jon Ralfio"})
window.chan.join().receive("ok",
  msg => {
    console.log("I joined a TicTacToe game")
    console.log(msg);
  }
)
window.chan.on("state",
  msg => {
    console.log("game state update")
    console.log(msg)
  }
)
