local luasnip = require("luasnip")

luasnip.config.set_config({
    history = true,
    updateevents = 'TextChanged,TextChangedI',
})

luasnip.add_snippets('php', {
    luasnip.parser.parse_snippet('class', 'class $1\n{\n    $0\n}'),
    luasnip.parser.parse_snippet('pubf', 'public function $1($2): $3\n{\n    $0\n}'),
    luasnip.parser.parse_snippet('prif', 'private function $1($2): $3\n{\n    $0\n}'),
    luasnip.parser.parse_snippet('prof', 'protected function $1($2): $3\n{\n    $0\n}'),
})

