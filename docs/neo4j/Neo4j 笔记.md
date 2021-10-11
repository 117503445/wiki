<!--
 * @Author: HaoTian Qi
 * @Date: 2021-08-10 15:39:54
 * @Description: 
 * @LastEditTime: 2021-08-10 18:57:40
 * @LastEditors: HaoTian Qi
-->

# Neo4j

## 基本概念

Neo4j 作为图数据库，肯定有 节点:node 和 关系:relationship。
关系是有向的。
每个 节点/关系，都可以有自己的 Label。Label 用于表示 节点/关系 的类型。
每个 节点/关系，都可以有自己的 propertys。propertys 相当于 Java 中的 map，以 key-value 的形式储存额外信息。

比如

节点 Label = Account, propertys = {address:"0x1000",exchange:"HuoBi"}
这个节点是个 Account，地址 0x1000，交易所是火币网

关系 Label = Buy, propertys = {coin:"bitcoin",cost:1}
这个关系是 购买，币种 比特币，金额 1 个

## 数据导入

ref

- <https://neo4j.com/developer/data-import/>
- <https://towardsdatascience.com/tagoverflow-correlating-tags-in-stackoverflow-66e2b0e1117b>
- <https://neo4j.com/developer/guide-importing-data-and-etl/>

Stack Overflow Dump (6.2GB) 包含 16.4M questions, 52k tags and 8.9M users

关系型数据 -> 图数据

> A row is a node, A table name is a label name, A join or foreign key is a relationship.

创建节点 -> 创建索引 Index -> 创建关系
