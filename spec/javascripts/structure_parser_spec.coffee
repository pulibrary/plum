describe "StructureParser", () ->
  structure = null
  describe "serialize", () ->
    describe "a single node", () ->
      beforeEach () ->
        loadFixtures('structure_basic.html')
        structure = new StructureParser($(".sortable"))
      it "returns a serialized form of the structure", ->
        expected_result = {
          'nodes': [
            {
              'label': 'Chapter 1'
            }
          ]
        }
        expect(structure.serialize).toEqual(expected_result)
    describe "two sibling nodes", () ->
      beforeEach () ->
        loadFixtures('structure_siblings.html')
        structure = new StructureParser($(".sortable"))
      it "returns a serialized form", ->
        expected_result = {
          "nodes": [
            {
              'label': 'Chapter 1'
            },
            {
              'label': 'Chapter 2'
            }
          ]
        }
        expect(structure.serialize).toEqual(expected_result)
    describe "nested nodes", () ->
      beforeEach () ->
        loadFixtures('structure_nested.html')
        structure = new StructureParser($(".sortable"))
      it "returns a serialized form", ->
        expected_result = {
          "nodes": [
            {
              'label': 'Chapter 1',
              'nodes': [
                {
                  'proxy': 'a'
                }
              ]
            }
          ]
        }
        expect(structure.serialize).toEqual(expected_result)
    describe "doubly-nested nodes", () ->
      beforeEach () ->
        loadFixtures('structure_double_nested.html')
        structure = new StructureParser($(".sortable"))
      it "returns a serialized form", ->
        expected_result = {
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "label": "Chapter 2",
                  "nodes": [
                    {
                      "proxy": "a"
                    }
                  ]
                }
              ]
            }
          ]
        }
        expect(structure.serialize).toEqual(expected_result)
    describe "complicated example", () ->
      beforeEach () ->
        loadFixtures('structure_1.html')
        structure = new StructureParser($(".sortable"))
      it "returns a serialized form", ->
        expected_result = {
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "proxy": "a"
                },
                {
                  "proxy": "b"
                }
              ]
            },
            {
              "label": "Chapter 2",
              "nodes": [
                {
                  "proxy": "c"
                },
                {
                  "proxy": "d"
                },
                {
                  "label": "Chapter 2a",
                  "nodes": [
                    {
                      "proxy": "e"
                    }
                  ]
                }
              ]
            }
          ]
        }
        expect(structure.serialize).toEqual(expected_result)

describe "StructureNode", () ->
  node = null
  beforeEach () ->
    loadFixtures('structure_basic.html')
    node = new StructureNode($('#node'))
  describe "label", () ->
    it "returns the value of the input", ->
      expect(node.label).toEqual("Chapter 1")
  describe "serialize", () ->
    it "returns a serialized object", ->
      expect(node.serialize).toEqual({"label": "Chapter 1"})
