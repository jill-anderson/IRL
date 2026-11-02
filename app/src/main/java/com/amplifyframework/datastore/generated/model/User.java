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

/** This is an auto generated class representing the User type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "Users", type = Model.Type.USER, version = 1, authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "owner", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.PUBLIC, operations = { ModelOperation.READ })
})
public final class User implements Model {
  public static final QueryField ID = field("User", "id");
  public static final QueryField EMAIL = field("User", "email");
  public static final QueryField USERNAME = field("User", "username");
  public static final QueryField DISPLAY_NAME = field("User", "displayName");
  public static final QueryField BIO = field("User", "bio");
  public static final QueryField PROFILE_PHOTO_URL = field("User", "profilePhotoUrl");
  public static final QueryField BIRTH_DATE = field("User", "birthDate");
  public static final QueryField GENDER = field("User", "gender");
  public static final QueryField LOCATION_PRIVACY = field("User", "locationPrivacy");
  public static final QueryField LAST_ACTIVE_AT = field("User", "lastActiveAt");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="AWSEmail", isRequired = true) String email;
  private final @ModelField(targetType="String", isRequired = true) String username;
  private final @ModelField(targetType="String", isRequired = true) String displayName;
  private final @ModelField(targetType="String") String bio;
  private final @ModelField(targetType="AWSURL") String profilePhotoUrl;
  private final @ModelField(targetType="AWSDate", isRequired = true) Temporal.Date birthDate;
  private final @ModelField(targetType="Gender", isRequired = true) Gender gender;
  private final @ModelField(targetType="LocationPrivacy", isRequired = true) LocationPrivacy locationPrivacy;
  private final @ModelField(targetType="AWSDateTime", isRequired = true) Temporal.DateTime lastActiveAt;
  private final @ModelField(targetType="CheckIn") @HasMany(associatedWith = "user", type = CheckIn.class) List<CheckIn> checkIns = null;
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
  
  public String getEmail() {
      return email;
  }
  
  public String getUsername() {
      return username;
  }
  
  public String getDisplayName() {
      return displayName;
  }
  
  public String getBio() {
      return bio;
  }
  
  public String getProfilePhotoUrl() {
      return profilePhotoUrl;
  }
  
  public Temporal.Date getBirthDate() {
      return birthDate;
  }
  
  public Gender getGender() {
      return gender;
  }
  
  public LocationPrivacy getLocationPrivacy() {
      return locationPrivacy;
  }
  
  public Temporal.DateTime getLastActiveAt() {
      return lastActiveAt;
  }
  
  public List<CheckIn> getCheckIns() {
      return checkIns;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private User(String id, String email, String username, String displayName, String bio, String profilePhotoUrl, Temporal.Date birthDate, Gender gender, LocationPrivacy locationPrivacy, Temporal.DateTime lastActiveAt) {
    this.id = id;
    this.email = email;
    this.username = username;
    this.displayName = displayName;
    this.bio = bio;
    this.profilePhotoUrl = profilePhotoUrl;
    this.birthDate = birthDate;
    this.gender = gender;
    this.locationPrivacy = locationPrivacy;
    this.lastActiveAt = lastActiveAt;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      User user = (User) obj;
      return ObjectsCompat.equals(getId(), user.getId()) &&
              ObjectsCompat.equals(getEmail(), user.getEmail()) &&
              ObjectsCompat.equals(getUsername(), user.getUsername()) &&
              ObjectsCompat.equals(getDisplayName(), user.getDisplayName()) &&
              ObjectsCompat.equals(getBio(), user.getBio()) &&
              ObjectsCompat.equals(getProfilePhotoUrl(), user.getProfilePhotoUrl()) &&
              ObjectsCompat.equals(getBirthDate(), user.getBirthDate()) &&
              ObjectsCompat.equals(getGender(), user.getGender()) &&
              ObjectsCompat.equals(getLocationPrivacy(), user.getLocationPrivacy()) &&
              ObjectsCompat.equals(getLastActiveAt(), user.getLastActiveAt()) &&
              ObjectsCompat.equals(getCreatedAt(), user.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), user.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getEmail())
      .append(getUsername())
      .append(getDisplayName())
      .append(getBio())
      .append(getProfilePhotoUrl())
      .append(getBirthDate())
      .append(getGender())
      .append(getLocationPrivacy())
      .append(getLastActiveAt())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("User {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("email=" + String.valueOf(getEmail()) + ", ")
      .append("username=" + String.valueOf(getUsername()) + ", ")
      .append("displayName=" + String.valueOf(getDisplayName()) + ", ")
      .append("bio=" + String.valueOf(getBio()) + ", ")
      .append("profilePhotoUrl=" + String.valueOf(getProfilePhotoUrl()) + ", ")
      .append("birthDate=" + String.valueOf(getBirthDate()) + ", ")
      .append("gender=" + String.valueOf(getGender()) + ", ")
      .append("locationPrivacy=" + String.valueOf(getLocationPrivacy()) + ", ")
      .append("lastActiveAt=" + String.valueOf(getLastActiveAt()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static EmailStep builder() {
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
  public static User justId(String id) {
    return new User(
      id,
      null,
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
      email,
      username,
      displayName,
      bio,
      profilePhotoUrl,
      birthDate,
      gender,
      locationPrivacy,
      lastActiveAt);
  }
  public interface EmailStep {
    UsernameStep email(String email);
  }
  

  public interface UsernameStep {
    DisplayNameStep username(String username);
  }
  

  public interface DisplayNameStep {
    BirthDateStep displayName(String displayName);
  }
  

  public interface BirthDateStep {
    GenderStep birthDate(Temporal.Date birthDate);
  }
  

  public interface GenderStep {
    LocationPrivacyStep gender(Gender gender);
  }
  

  public interface LocationPrivacyStep {
    LastActiveAtStep locationPrivacy(LocationPrivacy locationPrivacy);
  }
  

  public interface LastActiveAtStep {
    BuildStep lastActiveAt(Temporal.DateTime lastActiveAt);
  }
  

  public interface BuildStep {
    User build();
    BuildStep id(String id);
    BuildStep bio(String bio);
    BuildStep profilePhotoUrl(String profilePhotoUrl);
  }
  

  public static class Builder implements EmailStep, UsernameStep, DisplayNameStep, BirthDateStep, GenderStep, LocationPrivacyStep, LastActiveAtStep, BuildStep {
    private String id;
    private String email;
    private String username;
    private String displayName;
    private Temporal.Date birthDate;
    private Gender gender;
    private LocationPrivacy locationPrivacy;
    private Temporal.DateTime lastActiveAt;
    private String bio;
    private String profilePhotoUrl;
    public Builder() {
      
    }
    
    private Builder(String id, String email, String username, String displayName, String bio, String profilePhotoUrl, Temporal.Date birthDate, Gender gender, LocationPrivacy locationPrivacy, Temporal.DateTime lastActiveAt) {
      this.id = id;
      this.email = email;
      this.username = username;
      this.displayName = displayName;
      this.bio = bio;
      this.profilePhotoUrl = profilePhotoUrl;
      this.birthDate = birthDate;
      this.gender = gender;
      this.locationPrivacy = locationPrivacy;
      this.lastActiveAt = lastActiveAt;
    }
    
    @Override
     public User build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new User(
          id,
          email,
          username,
          displayName,
          bio,
          profilePhotoUrl,
          birthDate,
          gender,
          locationPrivacy,
          lastActiveAt);
    }
    
    @Override
     public UsernameStep email(String email) {
        Objects.requireNonNull(email);
        this.email = email;
        return this;
    }
    
    @Override
     public DisplayNameStep username(String username) {
        Objects.requireNonNull(username);
        this.username = username;
        return this;
    }
    
    @Override
     public BirthDateStep displayName(String displayName) {
        Objects.requireNonNull(displayName);
        this.displayName = displayName;
        return this;
    }
    
    @Override
     public GenderStep birthDate(Temporal.Date birthDate) {
        Objects.requireNonNull(birthDate);
        this.birthDate = birthDate;
        return this;
    }
    
    @Override
     public LocationPrivacyStep gender(Gender gender) {
        Objects.requireNonNull(gender);
        this.gender = gender;
        return this;
    }
    
    @Override
     public LastActiveAtStep locationPrivacy(LocationPrivacy locationPrivacy) {
        Objects.requireNonNull(locationPrivacy);
        this.locationPrivacy = locationPrivacy;
        return this;
    }
    
    @Override
     public BuildStep lastActiveAt(Temporal.DateTime lastActiveAt) {
        Objects.requireNonNull(lastActiveAt);
        this.lastActiveAt = lastActiveAt;
        return this;
    }
    
    @Override
     public BuildStep bio(String bio) {
        this.bio = bio;
        return this;
    }
    
    @Override
     public BuildStep profilePhotoUrl(String profilePhotoUrl) {
        this.profilePhotoUrl = profilePhotoUrl;
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
    private CopyOfBuilder(String id, String email, String username, String displayName, String bio, String profilePhotoUrl, Temporal.Date birthDate, Gender gender, LocationPrivacy locationPrivacy, Temporal.DateTime lastActiveAt) {
      super(id, email, username, displayName, bio, profilePhotoUrl, birthDate, gender, locationPrivacy, lastActiveAt);
      Objects.requireNonNull(email);
      Objects.requireNonNull(username);
      Objects.requireNonNull(displayName);
      Objects.requireNonNull(birthDate);
      Objects.requireNonNull(gender);
      Objects.requireNonNull(locationPrivacy);
      Objects.requireNonNull(lastActiveAt);
    }
    
    @Override
     public CopyOfBuilder email(String email) {
      return (CopyOfBuilder) super.email(email);
    }
    
    @Override
     public CopyOfBuilder username(String username) {
      return (CopyOfBuilder) super.username(username);
    }
    
    @Override
     public CopyOfBuilder displayName(String displayName) {
      return (CopyOfBuilder) super.displayName(displayName);
    }
    
    @Override
     public CopyOfBuilder birthDate(Temporal.Date birthDate) {
      return (CopyOfBuilder) super.birthDate(birthDate);
    }
    
    @Override
     public CopyOfBuilder gender(Gender gender) {
      return (CopyOfBuilder) super.gender(gender);
    }
    
    @Override
     public CopyOfBuilder locationPrivacy(LocationPrivacy locationPrivacy) {
      return (CopyOfBuilder) super.locationPrivacy(locationPrivacy);
    }
    
    @Override
     public CopyOfBuilder lastActiveAt(Temporal.DateTime lastActiveAt) {
      return (CopyOfBuilder) super.lastActiveAt(lastActiveAt);
    }
    
    @Override
     public CopyOfBuilder bio(String bio) {
      return (CopyOfBuilder) super.bio(bio);
    }
    
    @Override
     public CopyOfBuilder profilePhotoUrl(String profilePhotoUrl) {
      return (CopyOfBuilder) super.profilePhotoUrl(profilePhotoUrl);
    }
  }
  

  public static class UserIdentifier extends ModelIdentifier<User> {
    private static final long serialVersionUID = 1L;
    public UserIdentifier(String id) {
      super(id);
    }
  }
  
}
