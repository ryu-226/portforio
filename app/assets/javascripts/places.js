
  let map, markers = [];
  let myLocationMarker = null;
  let openInfoWindow = null;
  let currentCenter = { lat: 35.681236, lng: 139.767125 };
  let lastPlaces = [];
  let showFavOnly = false;
  let sortBy = "distance";
  let sortOrder = "asc";

  // お店ごとにユニークなキー（ID）を作る
  function markerPlaceKey(place) {
    return String(place.id) + "_" + place.location.latitude + "_" + place.location.longitude;
  }

  // お気に入り管理
  function getFavKeys() {
    return JSON.parse(localStorage.getItem("fav_places") || "[]");
  }
  function setFavKeys(keys) {
    localStorage.setItem("fav_places", JSON.stringify(keys));
  }
  function isFav(place) {
    return getFavKeys().includes(markerPlaceKey(place));
  }
  function toggleFav(place) {
    const key = markerPlaceKey(place);
    let favs = getFavKeys();
    if (favs.includes(key)) {
      favs = favs.filter(id => id !== key);
    } else {
      favs.push(key);
    }
    setFavKeys(favs);
    renderResultList(lastPlaces);
  }

  // 距離計算
  function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI/180;
    const dLon = (lon2 - lon1) * Math.PI/180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1*Math.PI/180) * Math.cos(lat2*Math.PI/180) *
              Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c * 1000;
  }

  // 並び替え
  function getSortedPlaces(places) {
    return places
      .map(place => {
        const dist = getDistance(currentCenter.lat, currentCenter.lng, place.location.latitude, place.location.longitude);
        return { ...place, _dist: dist };
      })
      .sort((a, b) => {
        let cmp = 0;
        if (sortBy === "distance") {
          cmp = a._dist - b._dist;
        } else if (sortBy === "rating") {
          cmp = (a.rating || 0) - (b.rating || 0);
        }
        return sortOrder === "asc" ? cmp : -cmp;
      });
  }

  // 検索結果リスト描画
  function renderResultList(places = []) {
    const list = document.getElementById("search-result-list");
    list.innerHTML = "";
    if (!places.length) return;

    const displayPlaces = showFavOnly ? places.filter(p => isFav(p)) : places;
    const sortedPlaces = getSortedPlaces(displayPlaces);
    const hitCountElement = document.getElementById("hit-count");
    if (hitCountElement) {
      hitCountElement.innerHTML = `検索結果 <span class="text-red-500 font-bold">${displayPlaces.length}</span> 件`;
    }
    if (!sortedPlaces.length) return;

    sortedPlaces.forEach((place, idx) => {
      const dist = place._dist ?? getDistance(currentCenter.lat, currentCenter.lng, place.location.latitude, place.location.longitude);
      const distLabel = dist < 1000 ? `${Math.round(dist)}m` : `${(dist/1000).toFixed(1)}km`;
      const icon = place.iconMaskBaseUri
        ? `<img src="${place.iconMaskBaseUri}.png" class="inline-block w-7 h-7 mr-2 align-middle rounded" style="background:${place.iconBackgroundColor||'#eee'};">`
        : "";

      const fav = isFav(place);
      const isGold = (place.rating || 0) >= 4.5;
      const cardClass = isGold ? "bg-yellow-100 border-2 border-yellow-400" : "bg-white";

      const card = document.createElement("div");
      card.className = `${cardClass} rounded-xl shadow p-3 flex flex-col gap-1 cursor-pointer hover:bg-gray-50 relative`;

      card.innerHTML = `
        <div class="flex items-center gap-2">
          <span class="text-xs font-bold rounded-full bg-gray-200 px-2 mr-1">${idx + 1}</span>
          ${icon}
          <span class="font-bold text-lg">${place.displayName.text}</span>
          <button type="button" class="ml-auto px-1 fav-btn" data-place-key="${markerPlaceKey(place)}">
            <span class="text-2xl select-none ${fav ? 'text-yellow-400' : 'text-gray-400'} hover:text-yellow-500 transition-colors">★</span>
          </button>
        </div>
        <div class="flex items-center ml-8">
          <div class="text-xs text-gray-500">${distLabel}</div>
        </div>
        <div class="text-gray-700 text-sm ml-8">${place.formattedAddress || ""}</div>
        <div class="flex items-center text-yellow-500 text-sm ml-8">${place.rating ? "★" + place.rating.toFixed(1) : ""}</div>
        <div class="ml-8">
          <a href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(place.displayName.text)}" 
            target="_blank" class="text-primary underline text-xs">Googleマップで見る</a>
        </div>
      `;

      // ピン連携
      card.addEventListener('click', () => {
        const key = markerPlaceKey(place);
        const marker = markers.find(m => m._placeKey === key);
        if (marker) {
          map.panTo(marker.getPosition());
          google.maps.event.trigger(marker, 'click');
        }
        window.scrollTo({ top: 0, behavior: "smooth" });
      });

      // お気に入りボタン
      card.querySelector('.fav-btn').addEventListener('click', function(e){
        e.stopPropagation();
        toggleFav(place);
      });

      list.appendChild(card);
    });
  }

  // マップ初期化・ピンなど
  function initMap() {
    map = new google.maps.Map(document.getElementById("map"), {
      center: currentCenter,
      zoom: 15,
    });

    map.addListener("click", () => {
      if (openInfoWindow) openInfoWindow.close();
    });

    if (!navigator.geolocation) {
      showResultMsg("位置情報取得機能がありません。");
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (position) => {
        currentCenter = {
          lat: position.coords.latitude,
          lng: position.coords.longitude
        };
        map.setCenter(currentCenter);
        addMyLocationMarker(currentCenter);
        doSearch(currentCenter);
      },
      (err) => {
        if (err.code === 1) {
          showResultMsg("位置情報の取得が許可されませんでした。ブラウザの設定を確認してください。");
        } else {
          showResultMsg("位置情報の取得に失敗しました。");
        }
        doSearch(currentCenter);
      }
    );
  }

  function addMyLocationMarker(center) {
    if (myLocationMarker) myLocationMarker.setMap(null);
    myLocationMarker = new google.maps.Marker({
      map: map,
      position: center,
      title: "現在地",
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        scale: 10,
        fillColor: "#2196f3",
        fillOpacity: 1,
        strokeWeight: 2,
        strokeColor: "#fff",
      }
    });
  }

  function addMarker(place, idx) {
    const isGold = (place.rating || 0) >= 4.5;
    const pinSvg = encodeURIComponent(`
      <svg width="44" height="44" xmlns="http://www.w3.org/2000/svg">
        <circle cx="22" cy="22" r="18" fill="${isGold ? '#FFD700' : '#ea4335'}" stroke="#fff" stroke-width="4"/>
        <text x="22" y="29" text-anchor="middle" font-size="20" fill="#fff" font-family="Arial" font-weight="bold">${idx+1}</text>
      </svg>
    `);

    const marker = new google.maps.Marker({
      map: map,
      position: {
        lat: place.location.latitude,
        lng: place.location.longitude
      },
      title: place.displayName.text,
      icon: {
        url: `data:image/svg+xml;utf8,${pinSvg}`,
        scaledSize: new google.maps.Size(44,44)
      }
    });
    marker._placeKey = markerPlaceKey(place);

    let ratingHtml = place.rating ? `評価: ★${place.rating.toFixed(1)}<br>` : '';
    let phoneHtml = place.nationalPhoneNumber ? `TEL: <a href="tel:${place.nationalPhoneNumber}" class="underline">${place.nationalPhoneNumber}</a><br>` : '';
    let webHtml = place.websiteUri ? `<a href="${place.websiteUri}" target="_blank" class="text-primary underline text-sm">公式サイト</a><br>` : '';
    let navHtml = `<a href="https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(place.displayName.text)}" target="_blank" class="text-primary underline text-sm">ナビ開始</a>`;

    const infowindow = new google.maps.InfoWindow({
      content: `
        <div class="p-2 min-w-[220px] relative">
          <b>${place.displayName.text}</b><br>
          ${place.formattedAddress || ''}<br>
          ${ratingHtml}
          ${phoneHtml}
          ${webHtml}
          <a href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(place.displayName.text)}"
             target="_blank" class="text-primary underline text-sm">
             Googleマップで見る
          </a><br>
          ${navHtml}
        </div>
      `
    });

    marker.addListener("click", () => {
      if (openInfoWindow) openInfoWindow.close();
      infowindow.open(map, marker);
      openInfoWindow = infowindow;
      window.openInfoWindow = infowindow;
    });
    markers.push(marker);
  }

  function clearMarkers() {
    markers.forEach(marker => marker.setMap(null));
    markers = [];
    if (openInfoWindow) openInfoWindow.close();
    openInfoWindow = null;
  }

  async function doSearch(center) {
    clearMarkers();

    const radius = Number(document.getElementById('radius')?.value) || 1000;
    let genre = document.getElementById('genre')?.value;
    const minRating = parseFloat(document.getElementById('min-rating')?.value) || 0;

    if (!genre) genre = "restaurant";

    let body = {
      includedTypes: [genre],
      languageCode: "ja",
      locationRestriction: {
        circle: {
          center: { latitude: center.lat, longitude: center.lng },
          radius: radius
        }
      }
    };

    try {
      const res = await fetch('/places/search', {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      });

      if (!res.ok) throw new Error("APIエラー");

      const data = await res.json();

      let filtered = (data.places || []).filter(p => (minRating ? (p.rating || 0) >= minRating : true));

      lastPlaces = filtered;

      if (!filtered.length) {
        showResultMsg("条件に合うお店が見つかりませんでした");
        document.getElementById("hit-count").textContent = "検索結果 0 件";
        renderResultList([]);
        return;
      } else {
        showResultMsg("");
        renderResultList(filtered);
      }

      getSortedPlaces(filtered).forEach((place, idx) => addMarker(place, idx));
    } catch (e) {
      showResultMsg("お店情報の取得に失敗しました。しばらくして再度お試しください");
      document.getElementById("hit-count").textContent = "";
      renderResultList([]);
    }
  }

  function showResultMsg(msg) {
    document.getElementById("search-result-msg").innerText = msg;
  }

  document.addEventListener("DOMContentLoaded", function() {
    document.getElementById("search-form").addEventListener("submit", function(e) {
      e.preventDefault();
      if (!navigator.geolocation) {
        showResultMsg("位置情報取得機能がありません。");
        return;
      }
      navigator.geolocation.getCurrentPosition(
        (position) => {
          let center = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
          };
          map.setCenter(center);
          addMyLocationMarker(center);
          doSearch(center);
        },
        (err) => {
          if (err.code === 1) {
            showResultMsg("位置情報の取得が許可されませんでした。ブラウザの設定を確認してください。");
          } else {
            showResultMsg("位置情報の取得に失敗しました。");
          }
          doSearch(currentCenter);
        }
      );
    });

    document.getElementById("fav-toggle").addEventListener("change", function(e) {
      showFavOnly = !!e.target.checked;
      renderResultList(lastPlaces);
    });

    document.getElementById("reload-location").addEventListener("click", function() {
      if (!navigator.geolocation) {
        showResultMsg("位置情報取得機能がありません。");
        return;
      }
      navigator.geolocation.getCurrentPosition(
        (position) => {
          let center = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
          };
          currentCenter = center;
          map.setCenter(center);
          addMyLocationMarker(center);
          doSearch(center);
        },
        (err) => {
          showResultMsg("現在地の取得に失敗しました");
        }
      );
    });

    // 並び替えイベント
    document.getElementById("sort-by").addEventListener("change", function(e){
      sortBy = e.target.value;
      renderResultList(lastPlaces);
    });
    document.getElementById("sort-order").addEventListener("change", function(e){
      sortOrder = e.target.value;
      renderResultList(lastPlaces);
    });

    // 説明バナー
    const desc = document.getElementById("location-desc");
    const closeBtn = document.getElementById("close-desc");
    if (localStorage.getItem("location_desc_shown")) {
      desc.style.display = "none";
    } else {
      desc.style.display = "";
      closeBtn.addEventListener("click", function() {
        desc.style.display = "none";
        localStorage.setItem("location_desc_shown", "1");
      });
    }
  });

  window.initMap = initMap;