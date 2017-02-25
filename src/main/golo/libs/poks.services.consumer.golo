module poks.services.consumer

import http
import JSON
import gololang.Async

function operations = |service_name| -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    let res = request(
      "GET",
      System.getenv(): get("SERVICES_URL")+"/"+service_name,
      null,
      [http.header("Content-Type", "application/json")]
    )
    let do = JSON.toDynamicObjectTreeFromString(res: data()) # list of operations

    let constructUrl = |urlBase, method, args...| {
      if(args is null) {
        return urlBase
      }

      if(method: equals("GET")) {
        return urlBase + "/" + Tuple.fromArray(args): join("/")
      } else {
        return urlBase
      }
    }

    let constructData = |method, args| {
      if(method: equals("GET")) {
        return null
      }
      if(method: equals("POST")) {
        return JSON.stringify(args)
      }
    }


    do: operations(): each(|operation| {
      # println("🤖 "+operation: name())
      # TODO test method if GET or POST
      operation: define(operation: name(), |this, args| {
        return promise(): initializeWithinThread(|resolve, reject| {
          try {

            let res = request(
              this: method(), # GET or POST
              constructUrl(this: url(), this: method(), args),
              constructData(this: method(), args),
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
