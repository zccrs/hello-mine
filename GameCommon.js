.pragma library

var GameStateEnum = {
    NormalState: 0,
    GameingState: 1,
    OverState: 2
}

function random(max) {
    return Math.random() * max;
}

function createBivariateArray(x, y, initValue) {
    var list = new Array(x);

    for (var i = 0; i < list.length; ++i) {
        list[i] = new Array(y);

        if (initValue !== undefined) {
            for (var j = 0; j < y; ++j) {
                list[i][j] = initValue;
            }
        }
    }

    return list;
}

function incrementArrayValue(array, x, y) {
    if (x < 0 || y < 0)
        return;

    if (x >= array.length)
        return;

    if (y >= array[x].length)
        return;

    if (typeof(array[x][y]) === "number") {
        // 如果是地雷，直接返回
        if (array[x][y] < 0)
            return;

        array[x][y] += 1;
     } else {
        array[x][y] = 1;
    }
}

function addMine(mineMap, mineX, mineY) {
    // 如果此处已经有地雷
    if (mineMap[mineX][mineY] === -1) {
        return false;
    }

    // 用-1表示地雷
    mineMap[mineX][mineY] = -1;
    incrementArrayValue(mineMap, mineX - 1, mineY);
    incrementArrayValue(mineMap, mineX - 1, mineY - 1);
    incrementArrayValue(mineMap, mineX, mineY - 1);
    incrementArrayValue(mineMap, mineX + 1, mineY - 1);
    incrementArrayValue(mineMap, mineX + 1, mineY);
    incrementArrayValue(mineMap, mineX + 1, mineY + 1);
    incrementArrayValue(mineMap, mineX, mineY + 1);
    incrementArrayValue(mineMap, mineX - 1, mineY + 1);

    return true;
}

function createMineMap(width, height, mineCount, safaIndex) {
    var mineMap = createBivariateArray(width, height);

    console.log("createMineMap", width, height, mineCount, safaIndex)

    for (var i = 0; i < mineCount; ) {
        var minePos = Math.floor(random(width * height));

        if (minePos === safaIndex)
            continue;

        if (addMine(mineMap, minePos % width, Math.floor(minePos / width)))
            ++i;
    }

    return mineMap;
}

function getMineMapValue(mineMap, x, y) {
    var value = mineMap[x][y];

    return value === undefined ? 0 : value;
}

function getMineMapValueByIndex(mineMap, width, index) {
    return getMineMapValue(mineMap, index % width, Math.floor(index / width))
}
