module poks.services.consumer

import http
import JSON
import gololang.Async

function operations = |operation_name| -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    let res = request(
      "GET",
      System.getenv(): get("SERVICES_URL")+"/"+operation_name,
      null,
      [http.header("Content-Type", "application/json")]
    )
    let do = JSON.toDynamicObjectTreeFromString(res: data()) # list of operations

    do: operations(): each(|operation| {
      # println("🤖 "+operation: name())
      # TODO test method if GET or POST
      operation: define("run", |this, args| {
        return promise(): initializeWithinThread(|resolve, reject| {
          try {
            let res = request(
              "GET",
              this: url()+"/"+args: join("/"),
              null,
              [http.header("Content-Type", "application/json")]
            )
            # struct response{code=200, message=OK, data={"a":7.0,"b":10.0,"r":70.0}}
            resolve(JSON.toDynamicObjectTreeFromString(res: data()))
          } catch (error) {
            reject(error)
          }
        }) # end return promise
      }) # end of define
    })

    resolve(do: operations())
  } catch(error) {
    reject(error)
  }
})
