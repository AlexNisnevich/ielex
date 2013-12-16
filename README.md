ielex
=====

Ruby scraper for IELex


### Example

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
