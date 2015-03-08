
module Rtasklib::Models

  class Task
    include Virtus.model

    # Default attributes from TW
    #
    # Required for every task
    attribute :status,        String
    attribute :uuid,          UUID
    attribute :entry,         Date
    attribute :description,   String
    # Optional for every task
    attribute :start,         Date
    attribute :until,         Date
    attribute :scheduled,     Date
    attribute :annotation,    Array[String]
    attribute :tags,          Array[String]
    attribute :project,       String
    attribute :priority,      String
    attribute :depends,       String
    # Required only for tasks that are Deleted or Completed
    attribute :end,           Date
    # Required only for tasks that are Waiting
    attribute :wait,          Date
    # Required only for tasks that are Recurring or have Recurring Parent
    attribute :recur,         Date
    # Optional except for tasks with Recurring Parents
    attribute :due,           Date
    # Required only for tasks that have Recurring Child
    attribute :parent,        UUID
    # Internal attributes should be read-only
    attribute :mask,          String
    attribute :imask,         String
    attribute :modified,      String

    # TODO: handle arbitrary UDA's

  end
end
