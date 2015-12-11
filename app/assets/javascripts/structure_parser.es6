/* exported StructureParser */
class StructureParser {
  constructor(element) {
    this.element = element
  }
  
  get serialize() {
    let start_obj = {}
    let nodes = []
    let children = $("> li", this.element)
    children.each((index, child) => {
      let node = new StructureNode($(child))
      nodes.push(node.serialize)
    })
    if(nodes.length > 0) {
      start_obj["nodes"] = nodes
    }
    return start_obj
  }
}

class StructureNode {
  constructor(element) {
    this.element = element
  }

  get serialize() {
    let new_obj = {}
    if(this.proxy) {
      new_obj["proxy"] = this.proxy
    }
    if(this.label) {
      new_obj["label"] = this.label
    }
    if(this.child_nodes.length > 0) {
      let nodes = []
      this.child_nodes.each((index, child) => {
        let node = new StructureParser($(child))
        for(let n of node.serialize["nodes"]) {
          nodes.push(n)
        }
      })
      new_obj["nodes"] = nodes
    }
    return new_obj
  }

  get proxy() {
    return this.element.attr("data-proxy")
  }

  get child_nodes() {
    return $("> ul", this.element)
  }

  get label() {
    let input_element = $("> div input", this.element)
    if(input_element.length > 0) {
      return input_element.val()
    }
  }
}
