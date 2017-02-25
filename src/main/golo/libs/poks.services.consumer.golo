module poks.services.consumer

import http
import JSON
import gololang.Async

function services =  -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    let res = request(
      "GET",
      System.getenv(): get("SERVICES_URL"),
      null,
      [http.header("Content-Type", "application/json")]
    )
    let strData = res: data()
    let data = JSON.parse(strData)
    #println("🍄  " + strData: getClass(): getSimpleName())
    #println("🍄  " + data: getClass(): getSimpleName())
    let servicesList = list[]
    data: each(|item| { servicesList: add(item) })
    resolve(servicesList)
  } catch (error) {
    reject(error)
  }
})

function operations = |service_name| -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    let res = request(
      "GET",
      System.getenv(): get("SERVICES_URL")+"/"+service_name,
      null,
      [http.header("Content-Type", "application/json")]
    )
    let do = JSON.toDynamicObjectTreeFromString(res: data()) # list of operations

    let constructUrl = |urlBase, args...| {
      if(args is null) {
        return urlBase
      } else {
        return urlBase + "/" + Tuple.fromArray(args): join("/")
      }
    }

    do: operations(): each(|operation| {

      if(operation: method(): equals("GET")) {
        do: define(operation: name(), |this, args...| {
          return promise(): initializeWithinThread(|resolve, reject| {
            try {
              let res = request(
                "GET",
                constructUrl(operation: url(), args),
                null,
                [http.header("Content-Type", "application/json")]
              )
              resolve(JSON.toDynamicObjectTreeFromString(res: data()))
            } catch (error) {
              reject(error)
            }
          }) # end return promise
        })# end of define
      }# end if

      if(operation: method(): equals("POST")) {
        do: define(operation: name(), |this, args| {
          println(JSON.stringify(args))
          return promise(): initializeWithinThread(|resolve, reject| {
            try {
              let res = request(
                "POST",
                operation: url(),
                JSON.stringify(args),
                [http.header("Content-Type", "application/json")]
              )
              resolve(JSON.toDynamicObjectTreeFromString(res: data()))
            } catch (error) {
              reject(error)
            }
          }) # end return promise
        })# end of define
      }# end if

    })# end each

    resolve(do)
  } catch(error) {
    reject(error)
  }
})
