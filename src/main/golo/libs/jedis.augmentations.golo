module jedis.augmentations

import redis.clients.jedis.Jedis

augment redis.clients.jedis.Jedis {
  function setAsJson = |this, key, model| -> this: set(key, JSON.stringify(model))
  function getFromJson = |this, key| -> JSON.toDynamicObject(this: get(key))
}
