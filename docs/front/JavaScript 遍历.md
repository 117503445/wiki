# JavaScript 遍历

## 数组

```js
arr = [1, 3, 5, 7, 9];
for (let i = 0; i < arr.length; i++) {
  console.log(arr[i]);
}
```

```js
arr = [1, 3, 5, 7, 9];
// for .. in 可枚举 (无顺序要求)
for (let i in arr) {
  console.log(arr[i]);
}
```

```js
arr = [1, 3, 5, 7, 9];
// for .. of 可迭代 (有顺序要求)
for (const v of arr) {
  console.log(v);
}
```

```js
arr = [1, 3, 5, 7, 9];
arr.forEach((v, i) => {
  console.log(i, v);
});
```

```js
arr = [1, 3, 5, 7, 9];
arr.forEach((v, i) => {
  arr[i] = v + 1; // 修改原数组的值
});
console.log(arr);
```

```js
arr = [1, 3, 5, 7, 9];
let newArr = arr.map((x) => x + 1); // 每个值 += 1
console.log(newArr);
```

```js
arr = [1, 3, 5, 7, 9];
let newArr = arr.filter((x) => x > 4); // 保留大于 4 的值
console.log(newArr);
```

## 对象

```js
let obj = { a: "0", b: "1", c: "2" };
for (let k in obj) {
  console.log(k, obj[k]);
}
```
