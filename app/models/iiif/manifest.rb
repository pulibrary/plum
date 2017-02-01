module IIIF
  class Manifest < Hash
    def label=(label)
      self['label'] = label
    end

    def description=(description)
      self['description'] = description
    end

    def viewing_hint=(viewing_hint)
      self['viewingHint'] = viewing_hint
    end

    def viewing_hint
      self['viewingHint']
    end

    def sequences
      self['sequences'] || []
    end

    def sequences=(sequences)
      self['sequences'] = sequences
    end

    def metadata=(metadata)
      self['metadata'] = metadata
    end

    def see_also=(see_also)
      self['seeAlso'] = see_also
    end

    def canvases
      self['canvases'] || []
    end

    def canvases=(canvases)
      self['canvases'] = canvases
    end
  end
end
