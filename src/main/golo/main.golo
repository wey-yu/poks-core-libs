module org.typeunsafe.poks.core

function main = |args| {
  println("Hello poks-core!")

  let a = [1,2,"56"]
  println(a: getClass(): getSimpleName())

  #oftype gololang.GoloAdapter.class
}
