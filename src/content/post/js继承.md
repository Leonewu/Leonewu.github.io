---
title: "javascript中的继承"
date: 2019-03-06T10:22:03+08:00
draft: false
tags: ["原型", '继承', 'prototype']
categories: ["前端基础知识"]
author: "leone"
comment: true
---
## <font color=#1abc9c>基本概念</font>
### <font color=#1abc9c>原型和原型链</font>
显式原型: prototype  
隐式原型: \_\_proto\_\_  
每一个对象都有 \_\_proto\_\_ 属性, 只有函数才有 prototype 属性  
对象的\_\_proto\_\_属性指向其构造函数的prototype
假设现在有以下代码
```
  function A() {
    this.name = 'oo'
  }
  let a = new A()
  // a = { name: 'oo' }
```
当a.name时,首先会在a自身找name,
找不到会一直沿着a.\_\_proto\_\_找,即a.\_\_proto\_\_.name,
再找不到就继续到a.\_\_proto\_\_.\_\_proto\_\_.name,依此类推...,会一直找到Object.prototype.\_\_proto\_\_,指到null,这就是原型链
而a.\_\_proto\_\_ 指向其构造函数(constructor)的prototype
因此,可有以下实现
```
  A.prototype.blog = 'leone'
  console.log(a.blog)
  // leone
```
### <font color=#1abc9c>new运算符</font>
new的时候做了三件事
```
  var obj  = {}
  obj.__proto__ = F.prototype
  F.call(obj)
```
### <font color=#1abc9c>Object.create()</font>
Object.create实际上就相当于
```
  Object.create = function (obj) {
    function F() {}
    F.prototype = obj
    return new F()
  }
  在组合继承中会用到
```
## <font color=#1abc9c>两种基本继承</font>
### <font color=#1abc9c>继承(原型继承)</font>
这样的话就通过改变原型链的指向,可以实现继承
```
  function A() {
    this.name = 'A'
    this.blog = 'leone'
  }
  function B() {
    this.name = 'B'
  }
  B.prototype = new A()
  let b = new B()
  console.log(b)
  // b: { name: 'B' }
  // 注意:继承后属性会覆盖,这里的blog并不是直接在b上面的,而是在B.prototype上的,所以console.log(b)并不会出现blog
  console.log(b.blog)
  //'leone'
```
这里为什么要这样写? 因为如果要让b能访问b.blog,根据原型链
b自身没有blog属性,所以到b.\_\_proto\_\_(即B.prototype找),指到一个有blog属性的对象就可以了
### <font color=#1abc9c>继承(构造函数继承)</font>
手动调用父类的构造函数
```
  function A() {
    this.name = 'A'
    this.blog = 'leone'
  }
  function B() {
    A.call(this)   //相当于es6中的super()
    this.name = 'B'
  }
  let b = new B()
  console.log(b)
  // b: {name: "B", blog: "leone"}
  console.log(b.blog)
  //'leone'
```
## <font color=#1abc9c>对比两种继承</font>
### <font color=#1abc9c>原型继承的缺点</font>
当出现复杂的引用类型时,就会导致多个实例共享同一个对象
```
  function A() {
    this.class = 'A'
    this.attr = { id: 'A', config: { type: 'A' } }
    this.info = { name: 'A', config: { type: 'A' } }
  }
  function B() {
    this.class = 'B'
    this.attr = { id: 'B', config: { type: 'B' } }
  }
  B.prototype = new A()
  let b = new B()
  let c = new B()
  b.attr.config.type = 'XX'
  b.info.config.type = 'XX'
  console.log(c.attr.config.type)   // B
  console.log(c.info.config.type)   // XX
```
如上,attr虽然也是引用类型对象,但是由于在B中重新声明了,所以是独立的
而info就被共享了  
构造函数继承就不会出现这种情况  
另外,原型继承还有个问题,就是 b.constructor === A // true  
constructor 会指到A去
### <font color=#1abc9c>构造函数继承的缺点</font>
构造函数虽然不会出现引用类型内存共享的情况  
1. new多个实例时，构造函数中的方法会在每个实例中拷贝一份，浪费内存(其实可以忽略不计)
2. 自己定义在prototype中的函数不会被继承到,如下  
```
  function A() {
    this.name = 'A'
    this.blog = 'leone'
  }
  A.prototype.fn = function (){
    //构造函数继承这个方法不会被继承到
    console.log(this.name)
  }
  function B() {
    A.call(this)   //相当于es6中的super()
    this.name = 'B'
  }
  let b = new B()
  console.log(b)
  // b: {name: "B", blog: "leone"}
  console.log(b.blog)
  //'leone'
  b.fn()
  // Uncaught TypeError: b.fn is not a function
```
## <font color=#1abc9c>组合继承</font>
组合继承解决了以上两种继承的缺点
原型继承和构造函数继承的组合
```
  function A() {
    this.class = 'A'
    this.attr = { id: 'A', config: { type: 'A' } }
    this.info = { name: 'A', config: { type: 'A' } }
  }
  A.prototype.fn = function (){
    console.log(this.info)
  }
  function B() {
    A.call(this)   //相当于es6中的super
    this.class = 'B'
    this.attr = { id: 'B', config: { type: 'B' } }
  }
  B.prototype = Object.create(A.prototype)
  // 复制A.prototype 附给B.prototype
  B.prototype.fn2 = function () {
    // B自己原型上的方法要写在下面,不然会被覆盖
    console.log(this.class)
  }
  let b = new B()
  let c = new B()
  b.attr.config.type = 'XX'
  b.info.config.type = 'XX'
  console.log(c.attr.config.type)   // B
  console.log(c.info.config.type)   // A
  b.fn()
  b.fn2()
```
注意:   
+ B.prototype = Object.create(A.prototype) 还有其他两种写法  
B.prototype = A.prototype，修改B.prototype就等于修改A.prototype，会干扰所有A的实例。  
B.prototype = new A()，A构造函数重复调用了两次（另一处调用是B构造函数中的A.call(this)），浪费效率，且如果A构造函数有副作用，重复调用可能造成不良后果.  
+ 组合继承还有一个需要注意的地方,就是当有复杂的引用类型的时候,不能写在父类的prototype里面,如A.prototype.obj = { desc: { name: 'obj' } },由于Object.create(A.prototype)是浅拷贝,所以每一个A的实例包括继承于A的类的实例,都会共享这个复杂引用对象。所以,使用组合继承时,如果父类有需要继承的复杂引用对象,一定要写在构造函数里,即this.obj = { desc: { name: 'obj' } }
## <font color=#1abc9c>es6中的类和继承</font>
其实类也是基于原型链的语法糖,相关可看[babel对class的转码](https://juejin.im/entry/5aa7f3ad518825555c1d5532)  
```
  class A {
    constructor(name, age) {
      this.name = name
      this.age = age
    }
    log() {
      console.log(this.name)
    }
    static id = 'A'
    static logId() {
      console.log(this.id)
    }
  }
  let a = new A('a', 12)
  a.log() // a
  a.id // undefined
  a.logId() // TypeError: a.logId is not a function
  class B extends A {
    constructor(name, age) {
      super(name, age)
      this.desc = 'B'
    }
    logB() {
      console.log(this.name)
    }
    logA() {
      super.logId()
    }
    static staticLogA() {
      //只能在静态方法里面用super.xx
      super.logId()
    }
  }
  let b = new B('b', 13)
  b.logA() //  logId is not a function
  b.staticLogA() // 'A'
```
### <font color=#1abc9c>关键字 extends super static</font>
+ __extends__  
继承关键字  
+ __static__   
表示静态方法或者静态对象,不会被实例的继承,也就是说实例中不会有父类static定义的东西,但是如果是会被继承到子类中去,比如上面的B.id打印出来会是'A'    
如果要在继承的实例里面使用父类的静态方法或属性,在上述例子,即b能调用A的logId方法,则需要在B中声明静态方法,然后通过super去调用,就是说,静态方法或属性只能给子类的静态方法中用super访问  
+ __super__  
super有两种用法,只有子类并且继承的时候用到  
super()即调用父类的构造函数  
super.xx访问父类的静态属性/方法,但是只有子类的静态方法里才能用super.xx  
## 参考
[js中\_\_proto\_\_和prototype的区别和关系？](https://www.zhihu.com/question/34183746)  
[js中继承的三种方式](https://segmentfault.com/a/1190000016525951)  
[从extends看js继承--知乎](https://juejin.im/entry/5aa7f3ad518825555c1d5532)  
[class的语法--阮一峰](http://es6.ruanyifeng.com/#docs/class)

