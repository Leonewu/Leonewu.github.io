---
# 常用定义
title: "关于箭头函数和react"
date: 2019-03-11T17:45:00+08:00
draft: true
tags: ['箭头函数']
categories: ['前端基础知识']
author: "leone"

# 用户自定义
# 你可以选择 关闭(false) 或者 打开(true) 以下选项
comment: true   # 关闭评论
toc: false       # 关闭文章目录
# 你同样可以自定义文章的版权规则
contentCopyright: '<a rel="license noopener" href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank">CC BY-NC-ND 4.0</a>'
reward: false	 # 关闭打赏
mathjax: true    # 打开 mathjax
---
### <font color=#1abc9c>问题</font>
1. 为什么react中有一部分函数要手动绑定this(bind)
2. 为什么react中箭头函数能替代手动绑定this
### <font color=#1abc9c>为什么react中要手动绑定this</font>
首先看一段代码
```
  a = {
    desc: 'a', 
    fn() {
      console.log(this.desc)
    }
  }
  a.fn() // a
  b = a.fn
  b() // undefined
```
因为在javascript中this指向的是函数的调用者,所以a.fn()这个时候this指向的是a,而b()相当于window.b()这个时候就指向了window,window.desc就返回了undefined   
再看一段react的代码  
```
class A extends React.component {
  constructor(props) {
    super(props)
    this.state = {
      desc: '哈哈哈'
    }
    // 如果click写成箭头函数就不用手动绑定this
    this.click = this.click.bind(this)
  }
  click() {
    this.setState({ desc: '哦哦哦' })
  }
  render() {
    const { desc } = this.state
    return (
      <div onClick={this.click}>{desc}</div>
    )
  }
}
```
而在react中,只有onClick,onChange这类函数才会出现this"不正常"的情况,这是因为在react中,对这一类回调是都是通过引用,也就是第一段代码的方式引用的,就会导致this的指向不是我们想要的
### <font color=#1abc9c>为什么箭头函数可以取代bind的写法</font>
因为箭头函数里没有this,所以箭头函数里的this就是上下文的this,而上下文的this就是声明类时候的this  
new的时候(let a = new A()),会把this指到新建的对象,所以说类里面箭头函数的this就是指向新建的对象,所以他的this不会随着调用的对象而改变,永远指向定义的时候的上下文的this  
总的来说,箭头函数里面的this在新建对象的时候就已经固定下来了  
而非箭头函数的this会随着调用者而改变  
```
  a = {
    desc: 'a', 
    fn: () => {
      console.log(this.desc)
      console.log(this === window)
    }
  }
  a.fn() // undefined  true
  // 说明箭头函数里面本来就没有this,它的this其实就是上下文的this
  b = a.fn
  b() // undefined true
```
下面的代码可以证明箭头函数里面的this不会由它的调用者改变而改变
```
function A() {
  this.desc = 'a'
  this.fn = () => {
    console.log(this.fn)
    console.log(this)
  }
}
a = new A()
a.fn()
// 'a' 
// A {desc: "a", fn: ƒ}
b = a.fn
b()
// 'a'
// A {desc: "a", fn: ƒ}
```
### 参考
[issue: React函数可以直接写？不用写成箭头函数的形式](https://github.com/umijs/umi/issues/1496)