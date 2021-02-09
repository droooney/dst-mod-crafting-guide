const fs = require('fs');
const path = require('path');

const map = [
    ['hermitcrab',    'critterlab',           'moon_altar'],
    ['ancient_altar', 'ancient_altar_broken'],
];
const mapWidth = 4;
const mapHeight = 2;

const elements = [];

for (const [y, row] of map.entries()) {
    for (const [x, prefab] of row.entries()) {
        elements.push(`<Element name="${prefab}.tex" u1="${x / mapWidth}" u2="${(x + 1) / mapWidth}" v1="${1 - (y + 1) / mapHeight}" v2="${1 - y / mapHeight}" />`);
    }
}

const atlasContents = `<Atlas>
    <Texture filename="icons.tex" />

    <Elements>
        ${elements.join('\n        ')}
    </Elements>
</Atlas>
`;

fs.writeFileSync(path.resolve('./images/icons.xml'), atlasContents);
