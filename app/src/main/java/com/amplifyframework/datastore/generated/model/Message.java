package com.amplifyframework.datastore.generated.model;

import com.amplifyframework.core.model.temporal.Temporal;
import com.amplifyframework.core.model.annotations.BelongsTo;
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

/** This is an auto generated class representing the Message type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "Messages", type = Model.Type.USER, version = 1, authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "senderId", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "recipientId", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class Message implements Model {
  public static final QueryField ID = field("Message", "id");
  public static final QueryField CONVERSATION_ID = field("Message", "conversationId");
  public static final QueryField SENDER_ID = field("Message", "senderId");
  public static final QueryField RECIPIENT_ID = field("Message", "recipientId");
  public static final QueryField CONTENT = field("Message", "content");
  public static final QueryField TIMESTAMP = field("Message", "timestamp");
  public static final QueryField STATUS = field("Message", "status");
  public static final QueryField CONVERSATION = field("Message", "conversationMessagesId");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="ID", isRequired = true) String conversationId;
  private final @ModelField(targetType="ID", isRequired = true) String senderId;
  private final @ModelField(targetType="ID", isRequired = true) String recipientId;
  private final @ModelField(targetType="String", isRequired = true) String content;
  private final @ModelField(targetType="AWSDateTime", isRequired = true) Temporal.DateTime timestamp;
  private final @ModelField(targetType="MessageStatus", isRequired = true) MessageStatus status;
  private final @ModelField(targetType="Conversation") @BelongsTo(targetName = "conversationMessagesId", targetNames = {"conversationMessagesId"}, type = Conversation.class) Conversation conversation;
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
  
  public String getConversationId() {
      return conversationId;
  }
  
  public String getSenderId() {
      return senderId;
  }
  
  public String getRecipientId() {
      return recipientId;
  }
  
  public String getContent() {
      return content;
  }
  
  public Temporal.DateTime getTimestamp() {
      return timestamp;
  }
  
  public MessageStatus getStatus() {
      return status;
  }
  
  public Conversation getConversation() {
      return conversation;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private Message(String id, String conversationId, String senderId, String recipientId, String content, Temporal.DateTime timestamp, MessageStatus status, Conversation conversation) {
    this.id = id;
    this.conversationId = conversationId;
    this.senderId = senderId;
    this.recipientId = recipientId;
    this.content = content;
    this.timestamp = timestamp;
    this.status = status;
    this.conversation = conversation;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      Message message = (Message) obj;
      return ObjectsCompat.equals(getId(), message.getId()) &&
              ObjectsCompat.equals(getConversationId(), message.getConversationId()) &&
              ObjectsCompat.equals(getSenderId(), message.getSenderId()) &&
              ObjectsCompat.equals(getRecipientId(), message.getRecipientId()) &&
              ObjectsCompat.equals(getContent(), message.getContent()) &&
              ObjectsCompat.equals(getTimestamp(), message.getTimestamp()) &&
              ObjectsCompat.equals(getStatus(), message.getStatus()) &&
              ObjectsCompat.equals(getConversation(), message.getConversation()) &&
              ObjectsCompat.equals(getCreatedAt(), message.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), message.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getConversationId())
      .append(getSenderId())
      .append(getRecipientId())
      .append(getContent())
      .append(getTimestamp())
      .append(getStatus())
      .append(getConversation())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("Message {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("conversationId=" + String.valueOf(getConversationId()) + ", ")
      .append("senderId=" + String.valueOf(getSenderId()) + ", ")
      .append("recipientId=" + String.valueOf(getRecipientId()) + ", ")
      .append("content=" + String.valueOf(getContent()) + ", ")
      .append("timestamp=" + String.valueOf(getTimestamp()) + ", ")
      .append("status=" + String.valueOf(getStatus()) + ", ")
      .append("conversation=" + String.valueOf(getConversation()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static ConversationIdStep builder() {
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
  public static Message justId(String id) {
    return new Message(
      id,
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
      conversationId,
      senderId,
      recipientId,
      content,
      timestamp,
      status,
      conversation);
  }
  public interface ConversationIdStep {
    SenderIdStep conversationId(String conversationId);
  }
  

  public interface SenderIdStep {
    RecipientIdStep senderId(String senderId);
  }
  

  public interface RecipientIdStep {
    ContentStep recipientId(String recipientId);
  }
  

  public interface ContentStep {
    TimestampStep content(String content);
  }
  

  public interface TimestampStep {
    StatusStep timestamp(Temporal.DateTime timestamp);
  }
  

  public interface StatusStep {
    BuildStep status(MessageStatus status);
  }
  

  public interface BuildStep {
    Message build();
    BuildStep id(String id);
    BuildStep conversation(Conversation conversation);
  }
  

  public static class Builder implements ConversationIdStep, SenderIdStep, RecipientIdStep, ContentStep, TimestampStep, StatusStep, BuildStep {
    private String id;
    private String conversationId;
    private String senderId;
    private String recipientId;
    private String content;
    private Temporal.DateTime timestamp;
    private MessageStatus status;
    private Conversation conversation;
    public Builder() {
      
    }
    
    private Builder(String id, String conversationId, String senderId, String recipientId, String content, Temporal.DateTime timestamp, MessageStatus status, Conversation conversation) {
      this.id = id;
      this.conversationId = conversationId;
      this.senderId = senderId;
      this.recipientId = recipientId;
      this.content = content;
      this.timestamp = timestamp;
      this.status = status;
      this.conversation = conversation;
    }
    
    @Override
     public Message build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new Message(
          id,
          conversationId,
          senderId,
          recipientId,
          content,
          timestamp,
          status,
          conversation);
    }
    
    @Override
     public SenderIdStep conversationId(String conversationId) {
        Objects.requireNonNull(conversationId);
        this.conversationId = conversationId;
        return this;
    }
    
    @Override
     public RecipientIdStep senderId(String senderId) {
        Objects.requireNonNull(senderId);
        this.senderId = senderId;
        return this;
    }
    
    @Override
     public ContentStep recipientId(String recipientId) {
        Objects.requireNonNull(recipientId);
        this.recipientId = recipientId;
        return this;
    }
    
    @Override
     public TimestampStep content(String content) {
        Objects.requireNonNull(content);
        this.content = content;
        return this;
    }
    
    @Override
     public StatusStep timestamp(Temporal.DateTime timestamp) {
        Objects.requireNonNull(timestamp);
        this.timestamp = timestamp;
        return this;
    }
    
    @Override
     public BuildStep status(MessageStatus status) {
        Objects.requireNonNull(status);
        this.status = status;
        return this;
    }
    
    @Override
     public BuildStep conversation(Conversation conversation) {
        this.conversation = conversation;
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
    private CopyOfBuilder(String id, String conversationId, String senderId, String recipientId, String content, Temporal.DateTime timestamp, MessageStatus status, Conversation conversation) {
      super(id, conversationId, senderId, recipientId, content, timestamp, status, conversation);
      Objects.requireNonNull(conversationId);
      Objects.requireNonNull(senderId);
      Objects.requireNonNull(recipientId);
      Objects.requireNonNull(content);
      Objects.requireNonNull(timestamp);
      Objects.requireNonNull(status);
    }
    
    @Override
     public CopyOfBuilder conversationId(String conversationId) {
      return (CopyOfBuilder) super.conversationId(conversationId);
    }
    
    @Override
     public CopyOfBuilder senderId(String senderId) {
      return (CopyOfBuilder) super.senderId(senderId);
    }
    
    @Override
     public CopyOfBuilder recipientId(String recipientId) {
      return (CopyOfBuilder) super.recipientId(recipientId);
    }
    
    @Override
     public CopyOfBuilder content(String content) {
      return (CopyOfBuilder) super.content(content);
    }
    
    @Override
     public CopyOfBuilder timestamp(Temporal.DateTime timestamp) {
      return (CopyOfBuilder) super.timestamp(timestamp);
    }
    
    @Override
     public CopyOfBuilder status(MessageStatus status) {
      return (CopyOfBuilder) super.status(status);
    }
    
    @Override
     public CopyOfBuilder conversation(Conversation conversation) {
      return (CopyOfBuilder) super.conversation(conversation);
    }
  }
  

  public static class MessageIdentifier extends ModelIdentifier<Message> {
    private static final long serialVersionUID = 1L;
    public MessageIdentifier(String id) {
      super(id);
    }
  }
  
}
