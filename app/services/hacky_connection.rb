class HackyConnection < SimpleDelegator
  def head(*)
    super
  end

  def get(*args)
    HackyGraphResponse.new(super)
  end

  def delete(*)
    super
  end

  def post(*)
    super
  end

  def put(uri, ttl)
    ttl = replace_objects(ttl, ActiveFedora.fedora.host, fake_path) if ttl.is_a?(String)
    super(uri, ttl)
  end

  def patch(uri, ttl, x)
    inserts = /INSERT \{ (.*?)\}/m.match(ttl).captures
    new_ttl = ttl
    inserts.each do |insert|
      insert.split("\n").each do |i|
        next if i.include?("http://www.w3.org/ns/ldp")
        next if i.blank?
        new_statement = i.gsub("> <#{ActiveFedora.fedora.host}", "> <#{fake_path}")
        new_ttl.gsub!(i, new_statement)
      end
    end
    super(uri, new_ttl, x)
  end

  private

    def replace_objects(ttl, base, fake_path)
      ::RDF::Writer.for(:ttl).buffer do |writer|
        ::RDF::Reader.for(:ttl).new(ttl).each_statement do |statement|
          if !statement.predicate.to_s.start_with?("http://www.w3.org/ns/ldp") && statement.object.is_a?(::RDF::URI) && statement.object.to_s.include?(base)
            writer << [statement.subject, statement.predicate, ::RDF::URI(statement.object.to_s.gsub(base, fake_path))]
          else
            writer << statement
          end
        end
      end
    end

    def fake_path
      "http://fake.com"
    end

    class HackyGraphResponse
      attr_reader :parent

      def initialize(parent)
        @parent = parent
      end

      def body
        parent.body
      end

      def reader
        @reader ||= RDF::Graph.new.tap do |g|
          each_statement.each do |statement|
            g << statement
          end
        end
      end

      def each_statement
        return to_enum(:each_statement) unless block_given?
        @each_statement ||= begin
                              parent.each_statement do |statement|
                                if statement.object.is_a?(::RDF::URI) && statement.object.to_s.include?("http://fake.com")
                                  yield RDF::Statement.from([statement.subject, statement.predicate, ::RDF::URI(statement.object.to_s.gsub("http://fake.com", ActiveFedora.fedora.host))])
                                else
                                  yield statement
                                end
                            end
        end
      end
    end
end
