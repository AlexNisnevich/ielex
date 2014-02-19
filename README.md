ielex
=====

Ruby scraper for IELex


### Examples

Write a JSON file of meanings and observed reflexes (except for English reflexes and non-nouns) 
indexed by protoform for the "body part" semantic field:

```ruby
require 'ielex'

reconstructions = IELex::SemanticField.find_by_name("body").first.reconstructions.map(&:entries)

json = reconstructions.map {|r| 
  r = r.select {|e| e.language != 'English' && e.pos.start_with?('n')}
  if r.length == 0
    {}
  else
    {r.first.protoform.protoform => 
      {
        'gloss' =>
          r.first.protoform.etymon,
        'meanings' => 
          r.map {|entry| entry.gloss.split(/[\,\;]/).map(&:strip) }.inject(&:+).uniq,
        'observed_reflexes' => 
          r.map {|e| {e.language => e.gloss.split(/[\,\;]/).map(&:strip)} }
           .reduce({}) {|accum, obj| accum.merge(obj) {|key, old, new| old + new} },
        'pos' =>
          r.map {|e| e.gloss.split(/[\,\;]/).map {|g| [g.strip, e.pos]}}.reduce(&:+)
      } 
    }
  end
}.inject(&:merge).to_json

File.open('ie_data.json', 'w') {|f| f.write json}
```

Write a JSON files of meanings and observed reflexes by protoform for all semantic fields:

```ruby
require 'ielex'

fields = IELex::SemanticField.all
fields = fields.map {|f| [f.name, f.reconstructions.map(&:entries)]}

json = fields.map {|f| 
  field = f[0]
  f[1].map {|r|
    r = r.select {|e| e.language != 'English' && e.pos.start_with?('n')}
    if r.length == 0
      {}
    else
      {r.first.protoform.protoform => 
        {
          'gloss' =>
            r.first.protoform.etymon,
          'meanings' => 
            r.map {|entry| entry.gloss.split(/[\,\;]/).map(&:strip) }.inject(&:+).uniq,
          'observed_reflexes' => 
            r.map {|e| {e.language.gsub("Proven al","Provencal") => e.gloss.split(/[\,\;]/).map(&:strip)} }
             .reduce({}) {|accum, obj| accum.merge(obj) {|key, old, new| old + new} },
          'pos' =>
            r.map {|e| e.gloss.split(/[\,\;]/).map {|g| [g.strip, e.pos]}}.reduce(&:+),
          'semanticField' => 
            field
        } 
      }
    end
  }.inject(&:merge)
}.inject(&:merge).to_json

File.open('ie_data_all_fields.json', 'w') {|f| f.write json}
```
