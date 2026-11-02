package com.amplifyframework.datastore.generated.model;

import com.amplifyframework.core.model.annotations.HasMany;
import com.amplifyframework.core.model.temporal.Temporal;
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

/** This is an auto generated class representing the Location type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "Locations", type = Model.Type.USER, version = 1, authRules = {
  @AuthRule(allow = AuthStrategy.PUBLIC, operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class Location implements Model {
  public static final QueryField ID = field("Location", "id");
  public static final QueryField NAME = field("Location", "name");
  public static final QueryField TYPE = field("Location", "type");
  public static final QueryField ADDRESS = field("Location", "address");
  public static final QueryField LATITUDE = field("Location", "latitude");
  public static final QueryField LONGITUDE = field("Location", "longitude");
  public static final QueryField GEOFENCE_ID = field("Location", "geofenceId");
  public static final QueryField RADIUS = field("Location", "radius");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="String", isRequired = true) String name;
  private final @ModelField(targetType="LocationType", isRequired = true) LocationType type;
  private final @ModelField(targetType="String", isRequired = true) String address;
  private final @ModelField(targetType="Float", isRequired = true) Double latitude;
  private final @ModelField(targetType="Float", isRequired = true) Double longitude;
  private final @ModelField(targetType="String", isRequired = true) String geofenceId;
  private final @ModelField(targetType="Float", isRequired = true) Double radius;
  private final @ModelField(targetType="CheckIn") @HasMany(associatedWith = "location", type = CheckIn.class) List<CheckIn> checkIns = null;
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
  
  public String getName() {
      return name;
  }
  
  public LocationType getType() {
      return type;
  }
  
  public String getAddress() {
      return address;
  }
  
  public Double getLatitude() {
      return latitude;
  }
  
  public Double getLongitude() {
      return longitude;
  }
  
  public String getGeofenceId() {
      return geofenceId;
  }
  
  public Double getRadius() {
      return radius;
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
  
  private Location(String id, String name, LocationType type, String address, Double latitude, Double longitude, String geofenceId, Double radius) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.address = address;
    this.latitude = latitude;
    this.longitude = longitude;
    this.geofenceId = geofenceId;
    this.radius = radius;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      Location location = (Location) obj;
      return ObjectsCompat.equals(getId(), location.getId()) &&
              ObjectsCompat.equals(getName(), location.getName()) &&
              ObjectsCompat.equals(getType(), location.getType()) &&
              ObjectsCompat.equals(getAddress(), location.getAddress()) &&
              ObjectsCompat.equals(getLatitude(), location.getLatitude()) &&
              ObjectsCompat.equals(getLongitude(), location.getLongitude()) &&
              ObjectsCompat.equals(getGeofenceId(), location.getGeofenceId()) &&
              ObjectsCompat.equals(getRadius(), location.getRadius()) &&
              ObjectsCompat.equals(getCreatedAt(), location.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), location.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getName())
      .append(getType())
      .append(getAddress())
      .append(getLatitude())
      .append(getLongitude())
      .append(getGeofenceId())
      .append(getRadius())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("Location {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("name=" + String.valueOf(getName()) + ", ")
      .append("type=" + String.valueOf(getType()) + ", ")
      .append("address=" + String.valueOf(getAddress()) + ", ")
      .append("latitude=" + String.valueOf(getLatitude()) + ", ")
      .append("longitude=" + String.valueOf(getLongitude()) + ", ")
      .append("geofenceId=" + String.valueOf(getGeofenceId()) + ", ")
      .append("radius=" + String.valueOf(getRadius()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static NameStep builder() {
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
  public static Location justId(String id) {
    return new Location(
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
      name,
      type,
      address,
      latitude,
      longitude,
      geofenceId,
      radius);
  }
  public interface NameStep {
    TypeStep name(String name);
  }
  

  public interface TypeStep {
    AddressStep type(LocationType type);
  }
  

  public interface AddressStep {
    LatitudeStep address(String address);
  }
  

  public interface LatitudeStep {
    LongitudeStep latitude(Double latitude);
  }
  

  public interface LongitudeStep {
    GeofenceIdStep longitude(Double longitude);
  }
  

  public interface GeofenceIdStep {
    RadiusStep geofenceId(String geofenceId);
  }
  

  public interface RadiusStep {
    BuildStep radius(Double radius);
  }
  

  public interface BuildStep {
    Location build();
    BuildStep id(String id);
  }
  

  public static class Builder implements NameStep, TypeStep, AddressStep, LatitudeStep, LongitudeStep, GeofenceIdStep, RadiusStep, BuildStep {
    private String id;
    private String name;
    private LocationType type;
    private String address;
    private Double latitude;
    private Double longitude;
    private String geofenceId;
    private Double radius;
    public Builder() {
      
    }
    
    private Builder(String id, String name, LocationType type, String address, Double latitude, Double longitude, String geofenceId, Double radius) {
      this.id = id;
      this.name = name;
      this.type = type;
      this.address = address;
      this.latitude = latitude;
      this.longitude = longitude;
      this.geofenceId = geofenceId;
      this.radius = radius;
    }
    
    @Override
     public Location build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new Location(
          id,
          name,
          type,
          address,
          latitude,
          longitude,
          geofenceId,
          radius);
    }
    
    @Override
     public TypeStep name(String name) {
        Objects.requireNonNull(name);
        this.name = name;
        return this;
    }
    
    @Override
     public AddressStep type(LocationType type) {
        Objects.requireNonNull(type);
        this.type = type;
        return this;
    }
    
    @Override
     public LatitudeStep address(String address) {
        Objects.requireNonNull(address);
        this.address = address;
        return this;
    }
    
    @Override
     public LongitudeStep latitude(Double latitude) {
        Objects.requireNonNull(latitude);
        this.latitude = latitude;
        return this;
    }
    
    @Override
     public GeofenceIdStep longitude(Double longitude) {
        Objects.requireNonNull(longitude);
        this.longitude = longitude;
        return this;
    }
    
    @Override
     public RadiusStep geofenceId(String geofenceId) {
        Objects.requireNonNull(geofenceId);
        this.geofenceId = geofenceId;
        return this;
    }
    
    @Override
     public BuildStep radius(Double radius) {
        Objects.requireNonNull(radius);
        this.radius = radius;
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
    private CopyOfBuilder(String id, String name, LocationType type, String address, Double latitude, Double longitude, String geofenceId, Double radius) {
      super(id, name, type, address, latitude, longitude, geofenceId, radius);
      Objects.requireNonNull(name);
      Objects.requireNonNull(type);
      Objects.requireNonNull(address);
      Objects.requireNonNull(latitude);
      Objects.requireNonNull(longitude);
      Objects.requireNonNull(geofenceId);
      Objects.requireNonNull(radius);
    }
    
    @Override
     public CopyOfBuilder name(String name) {
      return (CopyOfBuilder) super.name(name);
    }
    
    @Override
     public CopyOfBuilder type(LocationType type) {
      return (CopyOfBuilder) super.type(type);
    }
    
    @Override
     public CopyOfBuilder address(String address) {
      return (CopyOfBuilder) super.address(address);
    }
    
    @Override
     public CopyOfBuilder latitude(Double latitude) {
      return (CopyOfBuilder) super.latitude(latitude);
    }
    
    @Override
     public CopyOfBuilder longitude(Double longitude) {
      return (CopyOfBuilder) super.longitude(longitude);
    }
    
    @Override
     public CopyOfBuilder geofenceId(String geofenceId) {
      return (CopyOfBuilder) super.geofenceId(geofenceId);
    }
    
    @Override
     public CopyOfBuilder radius(Double radius) {
      return (CopyOfBuilder) super.radius(radius);
    }
  }
  

  public static class LocationIdentifier extends ModelIdentifier<Location> {
    private static final long serialVersionUID = 1L;
    public LocationIdentifier(String id) {
      super(id);
    }
  }
  
}
