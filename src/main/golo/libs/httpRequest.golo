module http

import gololang.Errors
import gololang.Async
import JSON

----
# isOk
Test if response is OK
----
function isOk = |code| -> [
  java.net.HttpURLConnection.HTTP_OK(),
  java.net.HttpURLConnection.HTTP_CREATED(),
  java.net.HttpURLConnection.HTTP_ACCEPTED()
]: exists(|value| -> value: equals(code))

struct response = {
  code,
  message,
  data
}

struct header = {
  property,
  value
}

function request = |method, uri, data, headers| {
  let obj = java.net.URL(uri) # URL obj
  let connection = obj: openConnection() # HttpURLConnection
  connection: setRequestMethod(method)

  headers: each(|item| {
    connection: setRequestProperty(item: property(), item: value())
  })

  if data isnt null and ("POST": equals(method) or "PUT": equals(method)) {
    connection: setDoOutput(true)
    let dataOutputStream = java.io.DataOutputStream(connection: getOutputStream())
    dataOutputStream: writeBytes(data)
    #dataOutputStream: writeBytes(JSON.stringify(data))
    dataOutputStream: flush()
    dataOutputStream: close()
  }

  let responseCode = connection: getResponseCode()
  let responseMessage = connection: getResponseMessage()

  if isOk(responseCode) {
    let responseText = java.util.Scanner(
      connection: getInputStream(),
      "UTF-8"
    ): useDelimiter("\\A"): next() # String responseText
    return response(responseCode, responseMessage, responseText)
    #return response(responseCode, responseMessage, JSON.parse(responseText))
  } else {
    return response(responseCode, responseMessage, null)
  }
}


function getJSONData = |path| -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    resolve(request("GET", path, null, [http.header("Content-Type", "application/json")]))
  } catch(error) {
    reject(error)
  }
})

function postJSONData = |path, data| -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    resolve(request("POST", path, JSON.stringify(data), [http.header("Content-Type", "application/json")]))
  } catch(error) {
    reject(error)
  }
})

function postJSONData = |path, data, credentials| -> promise(): initializeWithinThread(|resolve, reject| {
  try {
    resolve(request("POST", path, JSON.stringify(data), [
      http.header("Content-Type", "application/json"),
      http.header("Authorization", credentials)
    ]))
  } catch(error) {
    reject(error)
  }
})
