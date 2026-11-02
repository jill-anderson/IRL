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

/** This is an auto generated class representing the CheckIn type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "CheckIns", type = Model.Type.USER, version = 1, authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "owner", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.PUBLIC, operations = { ModelOperation.READ })
})
public final class CheckIn implements Model {
  public static final QueryField ID = field("CheckIn", "id");
  public static final QueryField USER_ID = field("CheckIn", "userId");
  public static final QueryField LOCATION_ID = field("CheckIn", "locationId");
  public static final QueryField CHECK_IN_TIME = field("CheckIn", "checkInTime");
  public static final QueryField CHECK_OUT_TIME = field("CheckIn", "checkOutTime");
  public static final QueryField STATUS = field("CheckIn", "status");
  public static final QueryField AUTO_CHECK_IN = field("CheckIn", "autoCheckIn");
  public static final QueryField USER = field("CheckIn", "userCheckInsId");
  public static final QueryField LOCATION = field("CheckIn", "locationCheckInsId");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="ID", isRequired = true) String userId;
  private final @ModelField(targetType="ID", isRequired = true) String locationId;
  private final @ModelField(targetType="AWSDateTime", isRequired = true) Temporal.DateTime checkInTime;
  private final @ModelField(targetType="AWSDateTime") Temporal.DateTime checkOutTime;
  private final @ModelField(targetType="CheckInStatus", isRequired = true) CheckInStatus status;
  private final @ModelField(targetType="Boolean", isRequired = true) Boolean autoCheckIn;
  private final @ModelField(targetType="User") @BelongsTo(targetName = "userCheckInsId", targetNames = {"userCheckInsId"}, type = User.class) User user;
  private final @ModelField(targetType="Location") @BelongsTo(targetName = "locationCheckInsId", targetNames = {"locationCheckInsId"}, type = Location.class) Location location;
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
  
  public String getUserId() {
      return userId;
  }
  
  public String getLocationId() {
      return locationId;
  }
  
  public Temporal.DateTime getCheckInTime() {
      return checkInTime;
  }
  
  public Temporal.DateTime getCheckOutTime() {
      return checkOutTime;
  }
  
  public CheckInStatus getStatus() {
      return status;
  }
  
  public Boolean getAutoCheckIn() {
      return autoCheckIn;
  }
  
  public User getUser() {
      return user;
  }
  
  public Location getLocation() {
      return location;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private CheckIn(String id, String userId, String locationId, Temporal.DateTime checkInTime, Temporal.DateTime checkOutTime, CheckInStatus status, Boolean autoCheckIn, User user, Location location) {
    this.id = id;
    this.userId = userId;
    this.locationId = locationId;
    this.checkInTime = checkInTime;
    this.checkOutTime = checkOutTime;
    this.status = status;
    this.autoCheckIn = autoCheckIn;
    this.user = user;
    this.location = location;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      CheckIn checkIn = (CheckIn) obj;
      return ObjectsCompat.equals(getId(), checkIn.getId()) &&
              ObjectsCompat.equals(getUserId(), checkIn.getUserId()) &&
              ObjectsCompat.equals(getLocationId(), checkIn.getLocationId()) &&
              ObjectsCompat.equals(getCheckInTime(), checkIn.getCheckInTime()) &&
              ObjectsCompat.equals(getCheckOutTime(), checkIn.getCheckOutTime()) &&
              ObjectsCompat.equals(getStatus(), checkIn.getStatus()) &&
              ObjectsCompat.equals(getAutoCheckIn(), checkIn.getAutoCheckIn()) &&
              ObjectsCompat.equals(getUser(), checkIn.getUser()) &&
              ObjectsCompat.equals(getLocation(), checkIn.getLocation()) &&
              ObjectsCompat.equals(getCreatedAt(), checkIn.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), checkIn.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getUserId())
      .append(getLocationId())
      .append(getCheckInTime())
      .append(getCheckOutTime())
      .append(getStatus())
      .append(getAutoCheckIn())
      .append(getUser())
      .append(getLocation())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("CheckIn {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("userId=" + String.valueOf(getUserId()) + ", ")
      .append("locationId=" + String.valueOf(getLocationId()) + ", ")
      .append("checkInTime=" + String.valueOf(getCheckInTime()) + ", ")
      .append("checkOutTime=" + String.valueOf(getCheckOutTime()) + ", ")
      .append("status=" + String.valueOf(getStatus()) + ", ")
      .append("autoCheckIn=" + String.valueOf(getAutoCheckIn()) + ", ")
      .append("user=" + String.valueOf(getUser()) + ", ")
      .append("location=" + String.valueOf(getLocation()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static UserIdStep builder() {
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
  public static CheckIn justId(String id) {
    return new CheckIn(
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
      userId,
      locationId,
      checkInTime,
      checkOutTime,
      status,
      autoCheckIn,
      user,
      location);
  }
  public interface UserIdStep {
    LocationIdStep userId(String userId);
  }
  

  public interface LocationIdStep {
    CheckInTimeStep locationId(String locationId);
  }
  

  public interface CheckInTimeStep {
    StatusStep checkInTime(Temporal.DateTime checkInTime);
  }
  

  public interface StatusStep {
    AutoCheckInStep status(CheckInStatus status);
  }
  

  public interface AutoCheckInStep {
    BuildStep autoCheckIn(Boolean autoCheckIn);
  }
  

  public interface BuildStep {
    CheckIn build();
    BuildStep id(String id);
    BuildStep checkOutTime(Temporal.DateTime checkOutTime);
    BuildStep user(User user);
    BuildStep location(Location location);
  }
  

  public static class Builder implements UserIdStep, LocationIdStep, CheckInTimeStep, StatusStep, AutoCheckInStep, BuildStep {
    private String id;
    private String userId;
    private String locationId;
    private Temporal.DateTime checkInTime;
    private CheckInStatus status;
    private Boolean autoCheckIn;
    private Temporal.DateTime checkOutTime;
    private User user;
    private Location location;
    public Builder() {
      
    }
    
    private Builder(String id, String userId, String locationId, Temporal.DateTime checkInTime, Temporal.DateTime checkOutTime, CheckInStatus status, Boolean autoCheckIn, User user, Location location) {
      this.id = id;
      this.userId = userId;
      this.locationId = locationId;
      this.checkInTime = checkInTime;
      this.checkOutTime = checkOutTime;
      this.status = status;
      this.autoCheckIn = autoCheckIn;
      this.user = user;
      this.location = location;
    }
    
    @Override
     public CheckIn build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new CheckIn(
          id,
          userId,
          locationId,
          checkInTime,
          checkOutTime,
          status,
          autoCheckIn,
          user,
          location);
    }
    
    @Override
     public LocationIdStep userId(String userId) {
        Objects.requireNonNull(userId);
        this.userId = userId;
        return this;
    }
    
    @Override
     public CheckInTimeStep locationId(String locationId) {
        Objects.requireNonNull(locationId);
        this.locationId = locationId;
        return this;
    }
    
    @Override
     public StatusStep checkInTime(Temporal.DateTime checkInTime) {
        Objects.requireNonNull(checkInTime);
        this.checkInTime = checkInTime;
        return this;
    }
    
    @Override
     public AutoCheckInStep status(CheckInStatus status) {
        Objects.requireNonNull(status);
        this.status = status;
        return this;
    }
    
    @Override
     public BuildStep autoCheckIn(Boolean autoCheckIn) {
        Objects.requireNonNull(autoCheckIn);
        this.autoCheckIn = autoCheckIn;
        return this;
    }
    
    @Override
     public BuildStep checkOutTime(Temporal.DateTime checkOutTime) {
        this.checkOutTime = checkOutTime;
        return this;
    }
    
    @Override
     public BuildStep user(User user) {
        this.user = user;
        return this;
    }
    
    @Override
     public BuildStep location(Location location) {
        this.location = location;
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
    private CopyOfBuilder(String id, String userId, String locationId, Temporal.DateTime checkInTime, Temporal.DateTime checkOutTime, CheckInStatus status, Boolean autoCheckIn, User user, Location location) {
      super(id, userId, locationId, checkInTime, checkOutTime, status, autoCheckIn, user, location);
      Objects.requireNonNull(userId);
      Objects.requireNonNull(locationId);
      Objects.requireNonNull(checkInTime);
      Objects.requireNonNull(status);
      Objects.requireNonNull(autoCheckIn);
    }
    
    @Override
     public CopyOfBuilder userId(String userId) {
      return (CopyOfBuilder) super.userId(userId);
    }
    
    @Override
     public CopyOfBuilder locationId(String locationId) {
      return (CopyOfBuilder) super.locationId(locationId);
    }
    
    @Override
     public CopyOfBuilder checkInTime(Temporal.DateTime checkInTime) {
      return (CopyOfBuilder) super.checkInTime(checkInTime);
    }
    
    @Override
     public CopyOfBuilder status(CheckInStatus status) {
      return (CopyOfBuilder) super.status(status);
    }
    
    @Override
     public CopyOfBuilder autoCheckIn(Boolean autoCheckIn) {
      return (CopyOfBuilder) super.autoCheckIn(autoCheckIn);
    }
    
    @Override
     public CopyOfBuilder checkOutTime(Temporal.DateTime checkOutTime) {
      return (CopyOfBuilder) super.checkOutTime(checkOutTime);
    }
    
    @Override
     public CopyOfBuilder user(User user) {
      return (CopyOfBuilder) super.user(user);
    }
    
    @Override
     public CopyOfBuilder location(Location location) {
      return (CopyOfBuilder) super.location(location);
    }
  }
  

  public static class CheckInIdentifier extends ModelIdentifier<CheckIn> {
    private static final long serialVersionUID = 1L;
    public CheckInIdentifier(String id) {
      super(id);
    }
  }
  
}
