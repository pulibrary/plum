require 'rdf/ntriples'
require 'vocab/pul_store'

class IngestEphemeraService
  def initialize(folder_dir, user, project, logger = Logger.new(STDOUT))
    @folder_dir = folder_dir
    @user = user
    @project = project
    @logger = logger
  end

  def ingest
    folder = EphemeraFolder.new local_identifier: [File.basename(@folder_dir)]
    folder.member_of_collections << find_or_create_box

    state = apply_prov(folder, @folder_dir)
    apply_desc(folder, @folder_dir)
    folder.pdf_type = ['none']
    folder.rights_statement = ['http://rightsstatements.org/vocab/NKC/1.0/']
    folder.save!
    @logger.info "Created folder: #{folder.id}"

    workflow_state = (state == 'In Production') ? 'complete' : 'needs_qa'
    Workflow::InitializeState.call folder, 'folder_works', workflow_state

    ingest_pages(folder)
  rescue => e
    @logger.warn "Error: #{e.message}"
    @logger.warn e.backtrace.join("\n")
  end

  def lookup(graph, predicate, vocab_label)
    graph.query([nil, predicate, nil]).map do |stmt|
      term_label = stmt.object.to_s
      if vocab_label
        vocabs[vocab_label] = Vocabulary.find_by(label: vocab_label) unless vocabs[vocab_label]
        term = VocabularyTerm.find_by(vocabulary: vocabs[vocab_label], label: term_label)
      else
        term = VocabularyTerm.find_by(label: term_label)
      end

      if term
        term.id.to_s
      else
        @logger.warn "Can't find #{vocab_label} >> #{term_label}"
        nil
      end
    end
  end

  private

    def find_or_create_box
      foxml = File.open("#{@folder_dir}/foxml") { |f| Nokogiri::XML(f) }
      box_id = foxml.xpath("//pulstore:inBox/@rdf:resource", namespaces).first.value
      box_id.gsub!(/.*:/, "")
      box = EphemeraBox.where(local_identifier_literals_ssim: box_id).first
      return box if box

      box = EphemeraBox.new local_identifier: [box_id]
      state = apply_prov(box, "#{basedir}/boxes/#{box_id}")
      box.ephemera_project = [EphemeraProject.find_by(name: @project).id.to_s]
      box.save!
      @logger.info "Created box: #{box.id}"

      # box workflow
      initialize_state(box, state)

      box
    end

    def initialize_state(box, state)
      Workflow::InitializeState.call(box, 'ephemera_box_works', state_map[state])
    end

    def basedir
      File.expand_path('../..', @folder_dir)
    end

    def namespaces
      {
        pulstore: 'http://princeton.edu/pulstore/terms/',
        rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
      }
    end

    def apply_prov(obj, dir)
      g = RDF::Graph.load("#{dir}/provMetadata")
      obj.barcode = value(g, ::PULStore.barcode)
      obj.folder_number = value(g, ::PULStore.physicalNumber) if obj.is_a?(EphemeraFolder)
      obj.box_number = value(g, ::PULStore.physicalNumber) if obj.is_a?(EphemeraBox)
      obj.visibility = (value(g, ::PULStore.suppressed) == 'true') ? visibility_private : visibility_public

      value(g, PULStore.state)
    end

    def apply_desc(folder, dir)
      g = RDF::Graph.load("#{dir}/descMetadata")
      folder.title = value(g, ::RDF::Vocab::DC.title)
      folder.alternative_title = value(g, ::RDF::Vocab::DC.alternative)
      folder.description = value(g, ::RDF::Vocab::DC.description)
      folder.publisher = value(g, ::RDF::Vocab::DC.publisher)
      folder.creator = value(g, ::RDF::Vocab::DC.creator)
      folder.contributor = value(g, ::RDF::Vocab::DC.contributor)
      folder.date_created = value(g, ::RDF::Vocab::DC.created)
      folder.genre = lookup(g, ::RDF::Vocab::DC.format, "LAE Genres").compact
      folder.geo_subject = lookup(g, ::RDF::Vocab::DC.coverage, "LAE Areas").compact
      folder.language = lookup(g, ::RDF::Vocab::DC.language, "LAE Languages").compact
      folder.subject = lookup(g, ::RDF::Vocab::DC.subject, nil).compact
    end

    def value(graph, predicate)
      stmt = graph.query([nil, predicate, nil]).first
      [stmt.object.to_s] if stmt && stmt.object.to_s
    end

    def ingest_pages(folder)
      files = page_folder_hash[folder.local_identifier.first].sort.map do |p|
        page_number = parse_page_number(p)
        file = master_image_hash[p].first
        ingest_service.ingest_file(folder, "#{basedir}/#{file}", @user, {}, title: [page_number])
      end
      folder.ordered_members = files
      folder.save!
    end

    def ingest_service
      @ingest_service ||= IngestService.new
    end

    def parse_page_number(page_id)
      g = RDF::Graph.load("#{basedir}/pages/#{page_id[0..1]}/#{page_id}/descMetadata")
      g.query([nil, ::PULStore.sortOrder, nil]).first.object.to_s
    end

    def master_image_hash
      @master_image_hash ||= read_hash("#{basedir}/masterImage.txt")
    end

    def page_folder_hash
      @page_folder_hash ||= read_hash("#{basedir}/pagefolders.txt")
    end

    def read_hash(filename)
      h = {}
      File.open(filename).each do |line|
        val, key = line.split(" ")
        h[key] = (h[key] || []).push(val)
      end

      h
    end

    def vocabs
      @vocabs ||= {}
    end

    def visibility_public
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    def visibility_private
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    def state_map
      @state_map ||= { 'New': 'new', 'Ready to Ship': 'ready_to_ship', 'Shipped': 'shipped',
                       'Received': 'received', 'All in Production': 'all_in_production' }.stringify_keys
    end
end
