--[[
Name: "sh_book_lr.lua".
Product: "HL2 RP".
--]]

ITEM = openAura.item:New();

ITEM.base = "book_base";
ITEM.name = "Little Red";
ITEM.model = "models/props_lab/binderredlabel.mdl";
ITEM.uniqueID = "book_lr";
ITEM.cost = 6;
ITEM.description = "A story book filled with colorful pictures.";
ITEM.bookInformation = [[
<font color='red' size='4'>Written by Benjamin Ishibashi.</font>

Once upon a time, there was a little girl who lived in a village near the forest.
Whenever, she went out, the little girl wore a red riding cloak, so everyone in the village called her Little Red Riding Hood.

One morning, Little Red Riding Hood asked her mother if she could go to visit her grandmother.
"That's a good idea!", her mother said. So they packed a nice basket for Little Red Riding Hood to take to her grandmother.

The grandmother lived out in the woods, a half hour from the village. When Little Red entered the woods a wolf came up to her.
She did not know what a wicked animal he was, and was not afraid of him.

"Good day to you, Little Red.", he said. "Thank you, wolf!", she replied. "Where are you going so early, Little Red?"
"To grandmothers.", she replied. "And what are you carrying under your apron?" He asked.
"Grandmother is sick and weak, and I am taking her some cake and wine. We baked yesterday, and they should give her strength."

The wolf thought to himself, "now there is a tasty bite for me. I'll go eat the grandmother, haha."
"Little Red, just where does your grandmother live?", he asked.

She told him that her house is a good half hour from here in the woods.
"A half hour? Screw that." he said, and then he ate the bitch. The end.

The moral of the story is to never approach talking wolves.
]];

openAura.item:Register(ITEM);