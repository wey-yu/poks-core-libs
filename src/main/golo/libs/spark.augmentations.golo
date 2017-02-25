module spark.augmentations

import spark.Spark

augment spark.Response {
  function jsonPayLoad = |this, content| {
    this: type("application/json")
    return gololang.JSON.stringify(content)
  }
  function textPayLoad = |this, content| {
    this: type("text/plain")
    return content
  }
}
