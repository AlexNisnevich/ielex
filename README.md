ielex
=====

Ruby scraper for IELex


### Example

Returning JSON file of meanings and observed reflexes indexed by protoform for the "body part" semantic field:

```ruby
require 'ielex'
reconstructions = IELex::SemanticField.find_by_name("body").first.reconstructions.map(&:entries)
reconstructions.map {|r| 
	{r.first.protoform.protoform => 
		{'meanings' => 
			r.map {|entry| entry.gloss.split(",") }.inject(&:+).uniq,
	 	 'observed_reflexes' => 
			r.map {|e| {e.language => e.gloss.split(",").map(&:strip)} }
			 .reduce({}) {|accum, obj| accum.merge(obj) {|key, old, new| old + new} }
		} 
	}
}.inject(&:merge).to_json
```
