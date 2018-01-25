---
layout: post
title: Python 黑魔法之 metaclass
toc: true
tags: ['Python']
cover: 'http://7xj74s.com1.z0.glb.clouddn.com/2018-01-25-12-53-09_r31.png'
---
<!-- 

time: 2016-03-22

cover: http://7xj74s.com1.z0.glb.clouddn.com/2018-01-25-12-53-09_r31.png



 -->





**翻译自** [stackoverflow](http://stackoverflow.com/questions/100003/what-is-a-metaclass-in-python#comment12037662_6581949)



## 什么是metaclass



`metaclass` 是类的类, 正如类定义了实例的行为, `metaclass` 定义了`class`的行为. `class` 是`metaclass`的实例.



<!-- more -->



---



`type`可以创建一个类, 实际上`type`就是一个`metaclass`:



```python

type(name of the class,

     tuple of the parent class (for inheritance, can be empty),

     dictionary containing attributes names and values)

```



比如:



```python

>>> class Foo(object):

...       bar = True

```



can be created manually this way:



```python

>>> Foo = type('Foo', (), {'bar':True})

```



如 str 创建 strings 对象, int 创建 int 对象, type 创建通用类对象



Python 中的所有东西都是对象, 都是由一个 class 创建的



通过`__class__`属性即可查看所属类



<!-- more -->



```python

>>> age = 35

>>> age.__class__

<type 'int'>  # int类

>>> name = 'bob'

>>> name.__class__

<type 'str'>  # str类

>>> def foo(): pass

>>> foo.__class__

<type 'function'>  # func类

>>> class Bar(object): pass

>>> b = Bar()

>>> b.__class__ # __main__.Bar类

<class '__main__.Bar'>

```



那`__class__`的`__class__`是什么呢?



```python

>>> age.__class__.__class__

<type 'type'>

```



因此, 元类`metaclass`就是创建所有类`class`对象的东西, 你可以把它当作是类的工厂



`type`是Python内置的元类, 你也可以创建自己的元类





---

### \__metaclass\__属性



当你写一个类的时候, 可以添加`__metaclass__`属性, 这样Python就会用该元类创建当前类了

```python

class Foo(object):

  __metaclass__ = something...

  [...]

```



注意, 这里非常tricky, 虽然你是先写的`class Foo`, 但是`Foo`还没有在内存里被创建呢



Python会先在类的定义中寻找`__metaclass__`属性, 如果找到了,就会用该元类创建类`Foo`, 如果没有找到, 就用`type`创建类`Foo`



```python

class Foo(Bar):

  pass

```



注意: `__metaclass__`是不会继承的, 而父类的元类(`Bar.__class__`)是会继承的, 比如`Bar`使用了一个用type()创建的`__metaclass__`属性( 非type.new() ), 那么子类是不会继承这个行为的





---



### 自定义 metaclass

`metaclass`的主要目的是在类创建时, 自动地改变类



通常会在`API`上用到, 你想要创建一个符合当前环境的类



这里举一个很二的栗子, 比如你想要模块内所有类的属性都用大写字母, 可以用在模块级别设置`__metaclass__`, 主要所有该模块的类都由该元类创建, 而我们只要告诉元类把所有属性转换为大写就可以咯



幸运的是, `__metaclass__`事实上可以是任何`可调用对象`, 不一定要是一个正式的类, 这里先用一个函数来实现



**以下有点问题, 我的测试和下列结果不符**

```python

# the metaclass will automatically get passed the same argument

# that you usually pass to `type`

def upper_attr(future_class_name, future_class_parents, future_class_attr):

  """

    Return a class object, with the list of its attribute turned

    into uppercase.

  """



  # pick up any attribute that doesn't start with '__' and uppercase it

  uppercase_attr = {}

  for name, val in future_class_attr.items():

      if not name.startswith('__'):

          uppercase_attr[name.upper()] = val

      else:

          uppercase_attr[name] = val



  # let `type` do the class creation

  return type(future_class_name, future_class_parents, uppercase_attr)



__metaclass__ = upper_attr # this will affect all classes in the module



class Foo(): # global __metaclass__ won't work with "object" though

  # but we can define __metaclass__ here instead to affect only this class

  # and this will work with "object" children

  bar = 'bip'



print(hasattr(Foo, 'bar'))

# Out: False

print(hasattr(Foo, 'BAR'))

# Out: True



f = Foo()

print(f.BAR)

# Out: 'bip'

```



现在来用一个真正的类作为元类



```python

# 记住 type 事实上是类, 如 str, int, 类可以由它继承

class UpperAttrMetaclass(type):

    # __new__ 是在 __init__ 之前被调用的方法

    # __new__ 创建对象, 并且返回对它

    # 而 __init__ 只是用初始化对象

    # 你很少用 __new__, 除非你很想控制对象如何创建

    # 这里要创建的对象是类, 我们要自定义它的创建

    # 这里覆盖 __new__

    # 你可以在__init__里做类似的事情如果你喜欢做一些高级的东西, 包括覆盖__call__之类的, 这里就不做了

    def __new__(upperattr_metaclass, future_class_name,

                future_class_parents, future_class_attr):



        uppercase_attr = {}

        for name, val in future_class_attr.items():

            if not name.startswith('__'):

                uppercase_attr[name.upper()] = val

            else:

                uppercase_attr[name] = val



        return type(future_class_name, future_class_parents, uppercase_attr)

```



不过这样写不太OOP, 我们直接调用了`type`, 而且没有覆盖或调用父类的`__new__`, 改一下:





```python

class UpperAttrMetaclass(type):



    def __new__(upperattr_metaclass, future_class_name,

                future_class_parents, future_class_attr):



        uppercase_attr = {}

        for name, val in future_class_attr.items():

            if not name.startswith('__'):

                uppercase_attr[name.upper()] = val

            else:

                uppercase_attr[name] = val



        # reuse the type.__new__ method

        # this is basic OOP, nothing magic in there

        return type.__new__(upperattr_metaclass, future_class_name,

                            future_class_parents, uppercase_attr)

```



也许你注意到了额外的参数`upperattr_metaclass`, 它没有什么特别的: `__new__`总是接受它所在的类作为第一个参数, 就像类内普通的函数接受实例作为第一个参数，也就是`self`.



当然, 这里的参数是为了更清楚地表示含义, 实际上`__new__`的参数有特定的名字, 真正的元类应该是如下的:



```python

class UpperAttrMetaclass(type):



    def __new__(cls, clsname, bases, dct):



        uppercase_attr = {}

        for name, val in dct.items():

            if not name.startswith('__'):

                uppercase_attr[name.upper()] = val

            else:

                uppercase_attr[name] = val



        return type.__new__(cls, clsname, bases, uppercase_attr)

```

既然是继承自`type`的, 那么用`super`更清楚明了



```python

class UpperAttrMetaclass(type):



    def __new__(cls, clsname, bases, dct):



        uppercase_attr = {}

        for name, val in dct.items():

            if not name.startswith('__'):

                uppercase_attr[name.upper()] = val

            else:

                uppercase_attr[name] = val



        return super(UpperAttrMetaclass, cls).__new__(cls, clsname, bases, uppercase_attr)

```



这个元类就这么多了



用了元类的代码背后的复杂性不是在于元类本身, 而是在于用元类所处理的依赖于内省, 继承操作, 变量(如`__dict__`)等麻烦之物



事实上, 元类做一些黑魔法特别游泳, 也因此成为了复杂的东西, 但是它自身是简单的:

- 拦截类的创建

- 修改类

- 返回类



### 为什么用`metaclass`而不是函数呢?

既然`__metaclass__`可以接受任何可调用对象, 为什么还是用类呢(相对更复杂)?



因为:

- 用类目的更明确, 当你读到`UpperAttrMetaclass(type)`, 你就知道接下来是干嘛了

- 用类可以运用OOP, 元类可以继承自元类, 覆盖父类方法, 元类也可以使用元类.

- 用类可以更好地结构化你的代码, 通常对复杂的代码比较有用, 也更易读

- 用类可以hook `__new__, __init__, __call__`, 它们允许你做不同的事情, 即使你可以全部在`__new__`完成, 一些人更喜欢用`__init__`

- 都叫做`metaclass`了, 肯定意味着什么





### 你为什么要用`metaclass`

现在有一个大问题, 你为什么要用一些易于隐晦出错的特性呢?



好吧, 通常你不真的需要

>Metaclass 是99%的用户不该担心的暗黑魔法. 如果你在想到底要不要用它, 你就不需要用它了, 需要用元类的人很清楚他们需要它

>

>*Python Guru Tim Peters*



`metaclass` 主要的使用场所是在设计API时, 一个典型的栗子是`Django ORM`, 它允许你这样写:



```python

class Person(models.Model):

	name = models.CharField(max_length=30)

	age = models.IntegerField()

```



但是如果你这样写:



```python

guy = Person(name='bob', age='35')

print(guy.age)

```

它是不会返回`IntegerField`对象的, 它会返回一个`int`, 甚至它还可以直接从数据库中取出



这是可能的, 因为`models.Model`定义了`__metaclass__`, 它用了一些魔法, 可以使得你用简单语句定义的`Person`变为复杂的关联数据域的钩子



`Django`通过简单的API以及使用`metaclass`将复杂的`hook`变得看起来挺简单, 通过这个API重建代码, 在幕后做真正的工作.



### 最后的话

首先, 你知道类是能创建实例的对象



事实上, 类本身也是实例, 是元类的实例



```python

>>> class Foo(object): pass

>>> id(Foo)

142630324

```



Python中所有的东西都是对象, 它们要么都是类的实例, 要么都是元类的实例.



而`type`除外



`type`是自身的元类, 这不是你能在纯Python里重现的, 这是通过在实现层做一些手脚实现的.



其次, `metaclass`是复杂的, 你也不想在很简单的类的改动上用到它, 你可以通过以下2种不同的方法改变类:



1. [monkey patching](http://en.wikipedia.org/wiki/Monkey_patch)

2. 类装饰器



99%的时候需要改动类, 最好用这两种方法



而99%的时候, 你根本不需要改变类



---



请原谅标点的使用
