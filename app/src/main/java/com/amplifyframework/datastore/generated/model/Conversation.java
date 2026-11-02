package com.amplifyframework.datastore.generated.model;

import com.amplifyframework.core.model.temporal.Temporal;
import com.amplifyframework.core.model.annotations.HasMany;
import com.amplifyframework.core.model.ModelIdentifier;

import java.util.List;
import java.util.UUID;
import java.util.Objects;

import androidx.core.util.ObjectsCompat;

import com.amplifyframework.core.model.AuthStrategy;
import com.amplifyframework.core.model.Model;
import com.amplifyframework.core.model.ModelOperation;
import com.amplifyframework.core.model.annotations.AuthRule;
import com.amplifyframework.core.model.annotations.Index;
import com.amplifyframework.core.model.annotations.ModelConfig;
import com.amplifyframework.core.model.annotations.ModelField;
import com.amplifyframework.core.model.query.predicate.QueryField;

import static com.amplifyframework.core.model.query.predicate.QueryField.field;

/** This is an auto generated class representing the Conversation type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "Conversations", type = Model.Type.USER, version = 1, authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "participant1Id", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "participant2Id", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class Conversation implements Model {
  public static final QueryField ID = field("Conversation", "id");
  public static final QueryField PARTICIPANT1_ID = field("Conversation", "participant1Id");
  public static final QueryField PARTICIPANT2_ID = field("Conversation", "participant2Id");
  public static final QueryField PARTICIPANT1_NAME = field("Conversation", "participant1Name");
  public static final QueryField PARTICIPANT2_NAME = field("Conversation", "participant2Name");
  public static final QueryField LAST_MESSAGE_TEXT = field("Conversation", "lastMessageText");
  public static final QueryField LAST_MESSAGE_TIME = field("Conversation", "lastMessageTime");
  public static final QueryField UNREAD_COUNT1 = field("Conversation", "unreadCount1");
  public static final QueryField UNREAD_COUNT2 = field("Conversation", "unreadCount2");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="ID", isRequired = true) String participant1Id;
  private final @ModelField(targetType="ID", isRequired = true) String participant2Id;
  private final @ModelField(targetType="String", isRequired = true) String participant1Name;
  private final @ModelField(targetType="String", isRequired = true) String participant2Name;
  private final @ModelField(targetType="String") String lastMessageText;
  private final @ModelField(targetType="AWSDateTime") Temporal.DateTime lastMessageTime;
  private final @ModelField(targetType="Int", isRequired = true) Integer unreadCount1;
  private final @ModelField(targetType="Int", isRequired = true) Integer unreadCount2;
  private final @ModelField(targetType="Message") @HasMany(associatedWith = "conversation", type = Message.class) List<Message> messages = null;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime createdAt;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime updatedAt;
  /** @deprecated This API is internal to Amplify and should not be used. */
  @Deprecated
   public String resolveIdentifier() {
    return id;
  }
  
  public String getId() {
      return id;
  }
  
  public String getParticipant1Id() {
      return participant1Id;
  }
  
  public String getParticipant2Id() {
      return participant2Id;
  }
  
  public String getParticipant1Name() {
      return participant1Name;
  }
  
  public String getParticipant2Name() {
      return participant2Name;
  }
  
  public String getLastMessageText() {
      return lastMessageText;
  }
  
  public Temporal.DateTime getLastMessageTime() {
      return lastMessageTime;
  }
  
  public Integer getUnreadCount1() {
      return unreadCount1;
  }
  
  public Integer getUnreadCount2() {
      return unreadCount2;
  }
  
  public List<Message> getMessages() {
      return messages;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private Conversation(String id, String participant1Id, String participant2Id, String participant1Name, String participant2Name, String lastMessageText, Temporal.DateTime lastMessageTime, Integer unreadCount1, Integer unreadCount2) {
    this.id = id;
    this.participant1Id = participant1Id;
    this.participant2Id = participant2Id;
    this.participant1Name = participant1Name;
    this.participant2Name = participant2Name;
    this.lastMessageText = lastMessageText;
    this.lastMessageTime = lastMessageTime;
    this.unreadCount1 = unreadCount1;
    this.unreadCount2 = unreadCount2;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      Conversation conversation = (Conversation) obj;
      return ObjectsCompat.equals(getId(), conversation.getId()) &&
              ObjectsCompat.equals(getParticipant1Id(), conversation.getParticipant1Id()) &&
              ObjectsCompat.equals(getParticipant2Id(), conversation.getParticipant2Id()) &&
              ObjectsCompat.equals(getParticipant1Name(), conversation.getParticipant1Name()) &&
              ObjectsCompat.equals(getParticipant2Name(), conversation.getParticipant2Name()) &&
              ObjectsCompat.equals(getLastMessageText(), conversation.getLastMessageText()) &&
              ObjectsCompat.equals(getLastMessageTime(), conversation.getLastMessageTime()) &&
              ObjectsCompat.equals(getUnreadCount1(), conversation.getUnreadCount1()) &&
              ObjectsCompat.equals(getUnreadCount2(), conversation.getUnreadCount2()) &&
              ObjectsCompat.equals(getCreatedAt(), conversation.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), conversation.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getParticipant1Id())
      .append(getParticipant2Id())
      .append(getParticipant1Name())
      .append(getParticipant2Name())
      .append(getLastMessageText())
      .append(getLastMessageTime())
      .append(getUnreadCount1())
      .append(getUnreadCount2())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("Conversation {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("participant1Id=" + String.valueOf(getParticipant1Id()) + ", ")
      .append("participant2Id=" + String.valueOf(getParticipant2Id()) + ", ")
      .append("participant1Name=" + String.valueOf(getParticipant1Name()) + ", ")
      .append("participant2Name=" + String.valueOf(getParticipant2Name()) + ", ")
      .append("lastMessageText=" + String.valueOf(getLastMessageText()) + ", ")
      .append("lastMessageTime=" + String.valueOf(getLastMessageTime()) + ", ")
      .append("unreadCount1=" + String.valueOf(getUnreadCount1()) + ", ")
      .append("unreadCount2=" + String.valueOf(getUnreadCount2()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static Participant1IdStep builder() {
      return new Builder();
  }
  
  /**
   * WARNING: This method should not be used to build an instance of this object for a CREATE mutation.
   * This is a convenience method to return an instance of the object with only its ID populated
   * to be used in the context of a parameter in a delete mutation or referencing a foreign key
   * in a relationship.
   * @param id the id of the existing item this instance will represent
   * @return an instance of this model with only ID populated
   */
  public static Conversation justId(String id) {
    return new Conversation(
      id,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
    );
  }
  
  public CopyOfBuilder copyOfBuilder() {
    return new CopyOfBuilder(id,
      participant1Id,
      participant2Id,
      participant1Name,
      participant2Name,
      lastMessageText,
      lastMessageTime,
      unreadCount1,
      unreadCount2);
  }
  public interface Participant1IdStep {
    Participant2IdStep participant1Id(String participant1Id);
  }
  

  public interface Participant2IdStep {
    Participant1NameStep participant2Id(String participant2Id);
  }
  

  public interface Participant1NameStep {
    Participant2NameStep participant1Name(String participant1Name);
  }
  

  public interface Participant2NameStep {
    UnreadCount1Step participant2Name(String participant2Name);
  }
  

  public interface UnreadCount1Step {
    UnreadCount2Step unreadCount1(Integer unreadCount1);
  }
  

  public interface UnreadCount2Step {
    BuildStep unreadCount2(Integer unreadCount2);
  }
  

  public interface BuildStep {
    Conversation build();
    BuildStep id(String id);
    BuildStep lastMessageText(String lastMessageText);
    BuildStep lastMessageTime(Temporal.DateTime lastMessageTime);
  }
  

  public static class Builder implements Participant1IdStep, Participant2IdStep, Participant1NameStep, Participant2NameStep, UnreadCount1Step, UnreadCount2Step, BuildStep {
    private String id;
    private String participant1Id;
    private String participant2Id;
    private String participant1Name;
    private String participant2Name;
    private Integer unreadCount1;
    private Integer unreadCount2;
    private String lastMessageText;
    private Temporal.DateTime lastMessageTime;
    public Builder() {
      
    }
    
    private Builder(String id, String participant1Id, String participant2Id, String participant1Name, String participant2Name, String lastMessageText, Temporal.DateTime lastMessageTime, Integer unreadCount1, Integer unreadCount2) {
      this.id = id;
      this.participant1Id = participant1Id;
      this.participant2Id = participant2Id;
      this.participant1Name = participant1Name;
      this.participant2Name = participant2Name;
      this.lastMessageText = lastMessageText;
      this.lastMessageTime = lastMessageTime;
      this.unreadCount1 = unreadCount1;
      this.unreadCount2 = unreadCount2;
    }
    
    @Override
     public Conversation build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new Conversation(
          id,
          participant1Id,
          participant2Id,
          participant1Name,
          participant2Name,
          lastMessageText,
          lastMessageTime,
          unreadCount1,
          unreadCount2);
    }
    
    @Override
     public Participant2IdStep participant1Id(String participant1Id) {
        Objects.requireNonNull(participant1Id);
        this.participant1Id = participant1Id;
        return this;
    }
    
    @Override
     public Participant1NameStep participant2Id(String participant2Id) {
        Objects.requireNonNull(participant2Id);
        this.participant2Id = participant2Id;
        return this;
    }
    
    @Override
     public Participant2NameStep participant1Name(String participant1Name) {
        Objects.requireNonNull(participant1Name);
        this.participant1Name = participant1Name;
        return this;
    }
    
    @Override
     public UnreadCount1Step participant2Name(String participant2Name) {
        Objects.requireNonNull(participant2Name);
        this.participant2Name = participant2Name;
        return this;
    }
    
    @Override
     public UnreadCount2Step unreadCount1(Integer unreadCount1) {
        Objects.requireNonNull(unreadCount1);
        this.unreadCount1 = unreadCount1;
        return this;
    }
    
    @Override
     public BuildStep unreadCount2(Integer unreadCount2) {
        Objects.requireNonNull(unreadCount2);
        this.unreadCount2 = unreadCount2;
        return this;
    }
    
    @Override
     public BuildStep lastMessageText(String lastMessageText) {
        this.lastMessageText = lastMessageText;
        return this;
    }
    
    @Override
     public BuildStep lastMessageTime(Temporal.DateTime lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
        return this;
    }
    
    /**
     * @param id id
     * @return Current Builder instance, for fluent method chaining
     */
    public BuildStep id(String id) {
        this.id = id;
        return this;
    }
  }
  

  public final class CopyOfBuilder extends Builder {
    private CopyOfBuilder(String id, String participant1Id, String participant2Id, String participant1Name, String participant2Name, String lastMessageText, Temporal.DateTime lastMessageTime, Integer unreadCount1, Integer unreadCount2) {
      super(id, participant1Id, participant2Id, participant1Name, participant2Name, lastMessageText, lastMessageTime, unreadCount1, unreadCount2);
      Objects.requireNonNull(participant1Id);
      Objects.requireNonNull(participant2Id);
      Objects.requireNonNull(participant1Name);
      Objects.requireNonNull(participant2Name);
      Objects.requireNonNull(unreadCount1);
      Objects.requireNonNull(unreadCount2);
    }
    
    @Override
     public CopyOfBuilder participant1Id(String participant1Id) {
      return (CopyOfBuilder) super.participant1Id(participant1Id);
    }
    
    @Override
     public CopyOfBuilder participant2Id(String participant2Id) {
      return (CopyOfBuilder) super.participant2Id(participant2Id);
    }
    
    @Override
     public CopyOfBuilder participant1Name(String participant1Name) {
      return (CopyOfBuilder) super.participant1Name(participant1Name);
    }
    
    @Override
     public CopyOfBuilder participant2Name(String participant2Name) {
      return (CopyOfBuilder) super.participant2Name(participant2Name);
    }
    
    @Override
     public CopyOfBuilder unreadCount1(Integer unreadCount1) {
      return (CopyOfBuilder) super.unreadCount1(unreadCount1);
    }
    
    @Override
     public CopyOfBuilder unreadCount2(Integer unreadCount2) {
      return (CopyOfBuilder) super.unreadCount2(unreadCount2);
    }
    
    @Override
     public CopyOfBuilder lastMessageText(String lastMessageText) {
      return (CopyOfBuilder) super.lastMessageText(lastMessageText);
    }
    
    @Override
     public CopyOfBuilder lastMessageTime(Temporal.DateTime lastMessageTime) {
      return (CopyOfBuilder) super.lastMessageTime(lastMessageTime);
    }
  }
  

  public static class ConversationIdentifier extends ModelIdentifier<Conversation> {
    private static final long serialVersionUID = 1L;
    public ConversationIdentifier(String id) {
      super(id);
    }
  }
  
}
