import React from 'react';
import { MapContainer, TileLayer, Marker, Popup, Circle } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Define custom marker icon
const defaultIcon = L.icon({
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

const redIcon = L.icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

const blueIcon = L.icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

const greenIcon = L.icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

const MapComponent = ({ 
  markers = [], 
  circles = [],
  center = [28.7041, 77.1025], // Default: Delhi, India
  zoom = 12,
  onMarkerClick = null
}) => {
  return (
    <MapContainer center={center} zoom={zoom} style={{ height: '100%', width: '100%', borderRadius: '8px' }}>
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; OpenStreetMap contributors'
      />
      
      {/* Render markers */}
      {markers.map((marker, index) => (
        <Marker 
          key={index} 
          position={[marker.lat, marker.lng]}
          icon={marker.icon || defaultIcon}
          eventHandlers={onMarkerClick ? {
            click: () => onMarkerClick(marker)
          } : {}}
        >
          <Popup>
            <div style={{ fontSize: '12px' }}>
              <strong>{marker.title}</strong>
              <p>{marker.description || ''}</p>
            </div>
          </Popup>
        </Marker>
      ))}
      
      {/* Render circles for geo-fencing zones */}
      {circles.map((circle, index) => (
        <Circle
          key={index}
          center={[circle.lat, circle.lng]}
          radius={circle.radius}
          color={circle.color || '#1890ff'}
          fillColor={circle.fillColor || '#1890ff'}
          fillOpacity={0.2}
          weight={2}
        >
          <Popup>
            <div style={{ fontSize: '12px' }}>
              <strong>{circle.title}</strong>
              {circle.description && <p>{circle.description}</p>}
            </div>
          </Popup>
        </Circle>
      ))}
    </MapContainer>
  );
};

export default MapComponent;
export { defaultIcon, redIcon, blueIcon, greenIcon };
