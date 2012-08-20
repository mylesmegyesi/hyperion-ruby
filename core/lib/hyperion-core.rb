module Hyperion
  class Core

  # {kind: "blog", title: "My awesome blog", body: "Enlitening Info"}

  class << self

    attr_writer :datastore

    def datastore
      @datastore || raise "No Datastore installed"
    end

    def save(record, attrs={})
      new_record record.merge(attrs)
      datastore.save([new_record]).first
    end

    def new?(record)
      record.has_key?(:id)
    end

    def save*(*records)
      datastore.save(records)
    end

    def find_by_id(kind, id)
      datastore.find_by_kind(kind, id)
    end

    def reload(record)
      datastore.find_by_id(record[:kind], record[:id])
    end

    def find_by_kind(kind, args={})
    end

    def find_all_kinds(args={})
    end

    def count_by_kind(kind, args={})
    end

    def count_all_kinds(args={})
    end

    def delete_by_id(kind, id)
    end

    def delete_by_kind(kind, args={})
    end

  end
end
