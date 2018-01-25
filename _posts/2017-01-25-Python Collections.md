---
layout: post
title: Python Collections
toc: true
tags: ['Python']
cover: 'http://7xj74s.com1.z0.glb.clouddn.com/2018-01-25-12-39-52_r80.png'
---
<!-- 

time: 2017-01-25

cover: http://7xj74s.com1.z0.glb.clouddn.com/2018-01-25-12-39-52_r80.png

 -->





`collections` 模块提供更高级的容器，来取代内置的`dict`, `set`, `tuple`。



<!-- more -->

## namedtuple()



namedtuple 函数以命名的字段创建 tuple 子类



> namedtuple(typename, field_names, verbose=False, rename=False)



field_names 可以是空格隔开的字符串，也可以是字符串的 list



```python

Point = namedtuple('Point', ['x', 'y'])

p = Point(11, y=22) # p 类似于 tuple, 可用下标访问 p[0] 或 p.x

>>> p                       

Point(x=11, y=22)

```







<!-- more -->



##  deque()



双端队列，读作`deck`，提供线程安全的，O(1) 效率的首位操作



注意：光是 append 和 pop 就像是 stack



```python

append(x) # 右端

apppendleft(x)

clear()

copy()

count(x)

extend(iterable)

extendleft(iterable)

index(x[,start[,stop]])

insert(i, x)

pop() # 右端

popleft()

remove(value)

reverse()

rotate(n) # 循环右移

maxlen()

```







## Counter()



Counter是创建可计数的哈希对象的 dict 子类







参数可以是`可迭代对象`如 list, str ，也可以是映射，如字典或参数赋值



```python

>>> c = Counter()                           # a new, empty counter

>>> c = Counter('gallahad')                 # a new counter from an iterable

>>> c = Counter({'red': 4, 'blue': 2})      # a new counter from a mapping

>>> c = Counter(cats=4, dogs=8)             # a new counter from keyword args

```







返回的是一个字典，value 为计数值，Counter 对象有三个函数



```python

c.elements() # 返回所有计数值大于0的元素的迭代器



c.most_common(n) # 返回n个最多的元素及其计数值

>>> Counter('abracadabra').most_common(3)

[('a', 5), ('r', 2), ('b', 2)]



c.subtract([iterable-or-mapping]) # 想减

>>> c = Counter(a=4, b=2, c=0, d=-2)

>>> d = Counter(a=1, b=2, c=3, d=4)

>>> c.subtract(d)

>>> c

Counter({'a': 3, 'b': 0, 'c': -3, 'd': -6})

```







顺便把 dict 的内容复习一下



```python

iter(d) # 相当于 iter(d.keys())，注意返回的是 key 的迭代器

clear()

copy() # 注意浅 copy 和深 copy 的区别

get(key[, default]) # 注意key 不在字典里会返回None，不抛异常

pop(key[,default]) # 若不在返回default，与上面不同default不给而key又不在会抛 KeyError 异常

items() # 返回 dict 的键值对视图（视图是动态反应dict的对象）

keys() # 返回 dict 的 key 视图

values() # 返回 dict 的 value 视图

popitem() # 删除并返回任意的键值对，常用于集合算法

setdefault(key[, default]) # 若在则返回其值，若不在则插入设为default并返回default，默认为None

update([other]) # 无则更新，有则覆盖

```







##  OrderedDict



让字典保持有序







##  defaultdict()



同样是 dict 的子类，第一个参数是 `default_factory`，需要提供初始的类型，默认是 None，相当于是给每个key的值默认初始化



defaultdict(some_type)







```python

>>> s = [('yellow', 1), ('blue', 2), ('yellow', 3), ('blue', 4), ('red', 1)]

>>> d = defaultdict(list)

>>> for k, v in s:

...     d[k].append(v)

...

>>> list(d.items())

[('blue', [2, 4]), ('red', [1]), ('yellow', [1, 3])]

```



类似于 dict.setdefault()







```python

>>> d = {}

>>> for k, v in s:

...     d.setdefault(k, []).append(v)

...

>>> list(d.items())

[('blue', [2, 4]), ('red', [1]), ('yellow', [1, 3])]



>>> s = 'mississippi'

>>> d = defaultdict(int)

>>> for k in s:

...     d[k] += 1

...

>>> list(d.items())

[('i', 4), ('p', 2), ('s', 4), ('m', 1)]

```


