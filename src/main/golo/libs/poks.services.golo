module poks.services

import http
import JSON
import gololang.Async
import gololang.concurrent.workers.WorkerEnvironment
import gololang.Errors

function heartBeat = |env, credentials| {
  # Hey 👋 server❗️ I'm alive❗️
  return env: spawn(|options| {
    while (options: stop() is false) {
      # promise
      http.postJSONData(
        options: serverUrl()+"/hey", # discovery server must have a `hey` route
        options: data(),
        credentials
      )
      : onSet(|result| { # if success
        println("❤️: " + result: data())
      })
      : onFail(|error| { # if failed
        println("😡: " + error: message())
      })
      sleep(options: refresh())
    }
    env: shutdown()
  })
}
