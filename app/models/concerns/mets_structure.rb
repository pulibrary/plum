module MetsStructure
  def structure
    structure_type('Logical') || structure_type('Physical') || structure_type('RelatedObjects')
  end

  def structure_for_volume(volume_id)
    volume = volume_nodes.find { |vol| vol.attribute("ID").value == volume_id }
    { nodes: structure_for_nodeset(volume.element_children) }
  end

  private

    def structure_type(type)
      top = @mets.xpath("/mets:mets/mets:structMap[@TYPE='#{type}']/mets:div/mets:div")
      return nil unless top.length > 0
      { nodes: structure_for_nodeset(top) }
    end

    def structure_for_nodeset(nodeset)
      nodes = []
      nodeset.each do |node|
        nodes << structure_recurse(node)
      end
      nodes
    end

    def structure_recurse(node)
      children = node.element_children
      return single_file_object(children.first) if single_file(children)

      child_nodes = []
      children.each do |child|
        child_nodes << structure_recurse(child)
      end
      { label: node['LABEL'], nodes: child_nodes }
    end

    def single_file(nodeset)
      nodeset.length == 1 && nodeset.first.name == 'fptr'
    end

    def single_file_object(node)
      id = node['FILEID']
      label = label_from_hierarchy(node.parent) || label_from_related_objects(id)
      { label: label, proxy: id }
    end

    def label_from_hierarchy(node)
      return nil unless node['LABEL']
      current = node
      label = current['LABEL']
      while current.parent['LABEL'] && allow_type(current.parent)
        label = "#{current.parent['LABEL']}. #{label}"
        current = current.parent
      end
      label
    end

    def allow_type(node)
      !['BoundVolume', 'Work'].include? node['TYPE']
    end

    def label_from_related_objects(id)
      @mets.xpath("/mets:mets/mets:structMap[@TYPE='RelatedObjects']//mets:div[mets:fptr/@FILEID='#{id}']/@LABEL").to_s
    end
end
