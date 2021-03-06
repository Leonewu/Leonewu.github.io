---
title: "算法-扑克牌问题"
date: 2019-03-05
lastmod: 2019-03-05
draft: false
tags: ["算法", "面试"]
categories: ["算法", "面试题"]
author: "leone"
comment: true
---



<!--more-->
## 题目

我手中有一堆扑克牌， 但是观众不知道它的顺序。

第一步， 我从牌顶拿出一张牌， 放到桌子上。

第二步， 我从牌顶再拿一张牌， 放在手上牌的底部。

第三步， 重复第一步、第二步的操作， 直到我手中所有的牌都放到了桌子上。

最后， 观众可以看到桌子上牌的顺序是：(牌底部）1,2,3,4,5,6,7,8,9,10,11,12,13(牌顶部）

请问， 我刚开始拿在手里的牌的顺序是什么？

请编程实现。

[链接](https://segmentfault.com/a/1190000017001391#articleHeader9)
## 实现
1. 定义数组从左到右未从顶到底,如```[1,2,3]```顶为1 (跟题目相反,所以结果会有点出入)
2. 先按照题目实现
3. 再反过来

### 放牌

```
// 左边为顶,右边为底
// 手顶拿一张,放一张桌子,手顶拿一张,放一张手底
// tmp 放到手底的牌
// table 放到桌子的牌
// hand 起始牌(手中)
// 逻辑: 循环,把手中的牌(hand)派到桌子上(table)和手底(tmp),递归直到tmp为空
function poker(hand, table) {
    let tmp = []
    hand.forEach((val, idx) => {
        if ((idx + 1) % 2) {
              table.unshift(val)
          } else {
              tmp.push(val)
          }
    })
    if (hand.length % 2) {
        // 奇数张,要放一张到手底
        let top = tmp.shift()
        top && tmp.push(top)
    }
    if (tmp.length) {
        poker(tmp, table)
    }
    return table
}
let a = poker([1, 2, 3], [])  // [2, 3, 1]
```
### 反过来
```
// 先考虑正向放牌
// (先把手顶的牌放桌子,再把手顶的牌放手底,就算手中只有一张牌或者没有牌,也会把'牌'放到手底)
// 所以最后一个动作是把牌放手底
// 反过来,第一个动作就是把手底的牌放在手顶,第二个动作才是把桌子顶部的牌放到手顶,如此反复...
// 直到桌子上没有牌,也就是说
// 对桌子上的牌进行遍历,每一次遍历都会把牌放到手顶,但这个动作的前一个动作是将手底的牌放到手顶
// 即使手中没有牌或者手中只有一张牌,都要进行这一个动作
function reversePoker(table) {
    let hand = []
    table.forEach(val => {
        let tmp = hand.pop()
        tmp && hand.unshift(tmp)
        hand.unshift(val)
    })
    return hand
}
let a = reversePoker([2, 3, 1], [])  // [1, 2, 3]
```
## 总结
每一个步骤都是两个动作的重复,不管是正向还是反向,只要保证这一点就可以




