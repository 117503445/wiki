# Neo4j cypher 代码片段

```cypher

CREATE (ee:Person { name: "Emil", from: "Sweden", klout: 99 })
# 创建一个 Label 为 Person 的节点，并附加一些 properties

MATCH (ee:Person) WHERE ee.name = "Emil" RETURN ee;
# 查找 Person Label 中 name 为 Emil 的 节点

MATCH (jennifer:Person {name: 'Jennifer'})
MATCH (mark:Person {name: 'Mark'})
CREATE (jennifer)-[rel:IS_FRIENDS_WITH]->(mark)
# 先找到 jennifer 和 mark，然后创建 IS_FRIENDS_WITH 的关系。如果不写 2 句 match，那么 Create 会 创建 重复的 Node。

MATCH (ee:Person)-[:KNOWS]-(friends)
WHERE ee.name = "Emil" RETURN ee, friends
# 查找与 Emil 有 KNOWS 关系 的节点，并把 Emil 和 friends 一起返回

MATCH (js:Person)-[:KNOWS]-()-[:KNOWS]-(surfer)
WHERE js.name = "Johan" AND surfer.hobby = "surfing"
RETURN DISTINCT surfer
# 查找 Johan 认识的人的认识的人里 有 hobby = surfing 的节点，并且使用 DISTINCT 防止重复返回

MATCH (tom:Person {name:'Tom Hanks'})-[rel:DIRECTED]-(movie:Movie)
RETURN tom.name AS name, tom.born AS `Year Born`, movie.title AS title, movie.released AS `Year Released`
# 使用 as，优化返回可读性

MATCH (p:Person {name: 'Jennifer'})
SET p.birthdate = date('1980-01-01')
RETURN p
# 找到 Jennifer，修改 propertys

MATCH (m:Person {name: 'Mark'})
DELETE m
# 删除 Mark
# 如果 Mark 节点 还存在 相关联的 relationship，就不能删除。

MATCH (j:Person {name: 'Jennifer'})-[r:IS_FRIENDS_WITH]->(m:Person {name: 'Mark'})
DELETE r
# 定位到 r 后，删除 r

MATCH (m:Person {name: 'Mark'})
DETACH DELETE m
# 强制删除 Mark，包含 相关联的 relationship

MATCH (n:Person {name: 'Jennifer'})
REMOVE n.birthdate
# 删除 property

MATCH (n:Person {name: 'Jennifer'})
SET n.birthdate = null
# 设置 property 为 null

MERGE (mark:Person {name: 'Mark'})
RETURN mark
# MERGE: 先试图查找，找不到就返回

MATCH (j:Person {name: 'Jennifer'})
MATCH (m:Person {name: 'Mark'})
MERGE (j)-[r:IS_FRIENDS_WITH]->(m)
RETURN j, r, m
# MERGE 关系，查不到就创建关系。如果没有 match，那么查不到时还会创建重复的节点。

MERGE (m:Person {name: 'Mark'})-[r:IS_FRIENDS_WITH]-(j:Person {name:'Jennifer'})
  ON CREATE SET r.since = date('2018-03-01')
  ON MATCH SET r.updated = date()
RETURN m, r, j
# 查不到，创建：设置 since
# 查到了： 更新 update

MATCH (j:Person)
WHERE NOT j.name = 'Jennifer'
RETURN j
# 查找 name 不是 Jennifer 的 Person Node
# boolean 操作符 支持 AND, OR, XOR, and NOT

MATCH (p:Person)
WHERE 3 <= p.yearsExp <= 7
RETURN p
# 数字范围查找 比用 and 更优雅

MATCH (p:Person)
WHERE exists(p.birthdate)
RETURN p.name
# 判断某个 node 是否有 某个 property

MATCH (p:Person)
WHERE p.name STARTS WITH 'M'
RETURN p.name
# 判断 以 substring 开头

MATCH (p:Person)
WHERE p.name CONTAINS 'a'
RETURN p.name
# 判断 存在 substring

MATCH (p:Person)
WHERE p.name ENDS WITH 'n'
RETURN p.name
# 判断 以 substring 结尾

MATCH (p:Person)
WHERE p.name =~ 'Jo.*'
RETURN p.name
# 正则表达式匹配

MATCH (p:Person)
WHERE p.yearsExp IN [1, 5, 6]
RETURN p.name, p.yearsExp
# IN 是否在某个给定列表中

MATCH (p:Person)-[r:IS_FRIENDS_WITH]->(friend:Person)
WHERE exists((p)-[:WORKS_FOR]->(:Company {name: 'Neo4j'}))
RETURN p, r, friend
# 查找 为Neo4j 工作的人的朋友
# 对关系使用查询语句


MATCH (p:Person)
WHERE p.name STARTS WITH 'J'
OPTIONAL MATCH (p)-[:WORKS_FOR]-(other:Company)
RETURN p.name, other.name
# Optional Patterns，类似 SQL 的外链接，匹配不成功的时候返回 null
# 返回 ("John","Neo4j"), ("JOJO",null)

MATCH (j:Person {name: 'Jennifer'})-[r:LIKES]-(graph:Technology {type: 'Graphs'})-[r2:LIKES]-(p:Person)
RETURN p.name
# find who likes graphs besides Jennifer
# 2 层关系

MATCH (j:Person {name: 'Jennifer'})-[:LIKES]->(:Technology {type: 'Graphs'})<-[:LIKES]-(p:Person),
      (j)-[:IS_FRIENDS_WITH]-(p)
RETURN p.name
# find who likes graphs besides Jennifer that she is also friends with
# 使用 2 条 MATCH 子句

MATCH (p:Person)
RETURN count(*);
# Person Node 的数量

MATCH (p:Person)
RETURN count(p.twitter);
# Person Node 且 有 twitter property 的数量

MATCH (p:Person)-[:IS_FRIENDS_WITH]->(friend:Person)
RETURN p.name, collect(friend.name) AS friend
# 根据 friend.name 进行聚合
# p.name  friend
# "sally" ["John","Jennifer"]
# "Dan"   ["Ann"]

MATCH (p:Person)-[:IS_FRIENDS_WITH]->(friend:Person)
RETURN p.name, size(collect(friend.name)) AS numberOfFriends;
# 聚合后，用 size 统计数量

MATCH (p:Person)-[:IS_FRIENDS_WITH]->(friend:Person)
WHERE size((friend)-[:IS_FRIENDS_WITH]-(:Person)) > 1
RETURN p.name, collect(friend.name) AS friends, size((friend)-[:IS_FRIENDS_WITH]-(:Person)) AS numberOfFoFs;
# 有其他朋友的朋友

MATCH (p:Person)-[:IS_FRIENDS_WITH]->(friend:Person)
WITH p, collect(friend.name) AS friendsList, size((friend)-[:IS_FRIENDS_WITH]-(:Person)) AS numberOfFoFs
WHERE numberOfFoFs > 1
RETURN p.name, friendsList, numberOfFoFs;
# 使用 WITH 子句，重定义变量，用于后续查询
# 没有在 WITH 中声明的，就无法传递到后续查询语句了

WITH 2 AS experienceMin, 6 AS experienceMax
MATCH (p:Person)
WHERE experienceMin <= p.yrsExperience <= experienceMax
RETURN p
# WITH 定义常量

WITH ['Graphs','Query Languages'] AS techRequirements
UNWIND techRequirements AS technology
MATCH (p:Person)-[r:LIKES]-(t:Technology {type: technology})
RETURN t.type, collect(p.name) AS potentialCandidates;
# UNWIND 与 collect 相反，会把 list 拆成分离的 rows

WITH ['Graphs','Query Languages'] AS techRequirements
UNWIND techRequirements AS technology
MATCH (p:Person)-[r:LIKES]-(t:Technology {type: technology})
WITH t.type AS technology, p.name AS personName
ORDER BY technology, personName
RETURN technology, collect(personName) AS potentialCandidates;
# ORDER BY 排序，默认递增

WITH [4, 5, 6, 7] AS experienceRange
UNWIND experienceRange AS number
MATCH (p:Person)
WHERE p.yearsExp = number
RETURN p.name, p.yearsExp ORDER BY p.yearsExp DESC;
# ORDER BY 排序，声明降序

MATCH (user:Person)
WHERE user.twitter IS NOT null
WITH user
MATCH (user)-[:LIKES]-(t:Technology)
WHERE t.type IN ['Graphs','Query Languages']
RETURN DISTINCT user.name
# 使用 DISTINCT 防止重复返回

MATCH (p:Person)-[r:IS_FRIENDS_WITH]-(other:Person)
RETURN p.name, count(other.name) AS numberOfFriends
ORDER BY numberOfFriends DESC
LIMIT 3
# LIMIT 返回限制



# 要找到一个 people 满足
# work for a company whose name starts with 'Company' and
# like at least one technology that’s liked by 3 or more people

MATCH (person:Person)-[:WORKS_FOR]->(company)
WHERE company.name STARTS WITH "Company"
AND (person)-[:LIKES]->(t:Technology)
AND size((t)<-[:LIKES]-()) >= 3
RETURN person.name as person, company.name AS company;
# 报错 Variable `t` not defined (line 4, column 25 (offset: 112))

MATCH (person:Person)-[:WORKS_FOR]->(company)
WHERE company.name STARTS WITH "Company"
AND EXISTS {
  MATCH (person)-[:LIKES]->(t:Technology)
  WHERE size((t)<-[:LIKES]-()) >= 3
}
RETURN person.name as person, company.name AS company;
# EXISTS {} 子查询
```
