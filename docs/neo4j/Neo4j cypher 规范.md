# Cypher 规范

ref <https://neo4j.com/developer/cypher/style-guide/>

## 命名

Node Labels 使用 CamelCase 风格，首字母大写

- (:Person)
- (:NetworkAddress)
- (:VeryDescriptiveLabel)

Relationship Types 使用 大写 下划线 风格

- [:FOLLOWS]
- [:ACTED_IN]
- [:IS_IN_LOVE_WITH]

属性键、变量、参数、别名和函数 使用 使用 CamelCase 风格，首字母小写

title
size()
businessAddress
firstName
customerAccountNumber
allShortestPaths()

Clauses 就是 MATCH WHERE 之类的，全部大写，全部放在新行的开头。

```cypher
MATCH (n:Person)
WHERE n.name = 'Bob'
RETURN n;

WITH "1980-01-01" as birthdate
MATCH (person:Person)
WHERE person.birthdate > birthdate
RETURN person.name;
```

Keywords 包括 DISTINCT, IN, STARTS WITH, CONTAINS, NOT, AS, AND 全部大写，不另起新行。

```cypher
MATCH (p:Person)-[:VISITED]-(place:City)
RETURN collect(DISTINCT place.name);

MATCH (a:Airport)
RETURN a.airportIdentifier as AirportCode;

MATCH (c:Company)
WHERE c.name CONTAINS 'Inc.' AND c.startYear IN [1990, 1998, 2007, 2010]
RETURN c;
```

null true false 用小写

```cypher
//null and boolean values are lower case
MATCH (p:Person)
WHERE p.birthdate = null
  SET missingBirthdate = true
RETURN p
```

## 其他

子句在新行缩进 2 个空格

```cypher
//indent 2 spaces on lines with ON CREATE or ON MATCH
MATCH (p:Person {name: 'Alice'})
MERGE (c:Company {name: 'Wayne Enterprises'})
MERGE (p)-[rel:WORKS_FOR]-(c)
  ON CREATE SET rel.startYear = date({year: 2018})
  ON MATCH SET rel.updated = date()
RETURN p, rel, c;

//indent 2 spaces with braces for subqueries
MATCH (p:Person)
WHERE EXISTS {
  MATCH (p)-->(c:Company)
  WHERE c.name = 'Neo4j'
}
RETURN p.name;
```

子查询只有 1 句时，不起新行不缩进。

```cypher
//indent 2 spaces without braces for 1-line subqueries
MATCH (p:Person)
WHERE EXISTS { MATCH (p)-->(c:Company) }
RETURN p.name
```

字符串优先使用 ''，但如果产生了过多的转义\'，就使用 ""

- RETURN 'nice'
- RETURN "Cypher's a nice language", 'Mats\' quote: "statement"'

单查询 Cypher 不加末尾分号，多查询 Cypher 加末尾分号

```cypher
MATCH (c:Company {name: 'Neo4j'})
RETURN c

```

```cypher
MATCH (c:Company {name: 'Neo4j'})
RETURN c;

MATCH (p:Person)
WHERE p.name = 'Jennifer'
RETURN p;

MATCH (t:Technology)-[:LIKES]-(a:Person {name: 'Jennifer'})
RETURN t.type;
```

在 pattern 的 箭头后换行

```cypher
MATCH (:Person)-->(vehicle:Car)-->(:Company)<--
      (:Country)
RETURN count(vehicle)
```

不引入不必要的变量

```cypher
MATCH (:Person {name: 'Kate'})-[:LIKES]-(c:Car)
RETURN c.type
```

把开始节点放在MATCH的最前面，尽量把有变量的节点放前面

```cypher
MATCH (manufacturer:Company)<--(vehicle:Car)<--()
WHERE manufacturer.foundedYear < 2000
RETURN vehicle.mileage
```
