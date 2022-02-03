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
        elements.push(Element(prefab, x, y, 1, 1));
    }
}

elements.push(Element('checkmark', 3, 0, 0.5, 0.5));
elements.push(Element('cross', 3.5, 0, 0.5, 0.5));
elements.push(Element('question', 3, 0.5, 0.5, 0.5));

const atlasContents = `<Atlas>
    <Texture filename="icons.tex" />

    <Elements>
        ${elements.join('\n        ')}
    </Elements>
</Atlas>
`;

fs.writeFileSync(path.resolve('./images/CraftingGuide/icons.xml'), atlasContents);

function Element(prefab, x, y, width, height) {
    return `<Element name="${prefab}.tex" u1="${x / mapWidth}" u2="${(x + width) / mapWidth}" v1="${1 - (y + height) / mapHeight}" v2="${1 - y / mapHeight}" />`;
}
