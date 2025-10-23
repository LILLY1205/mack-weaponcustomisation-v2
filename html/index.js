(function(){
  const resource = (window.GetParentResourceName && GetParentResourceName()) || 'mack-weaponcustomisation-v2';
  const qs = (s)=>document.querySelector(s);

  const container = qs('#container');
  const grid = qs('#shared_table');
  const priceLabel = qs('#component_for_buy');
  const btnPay = qs('#pay_weapos');
  const closeBtn = qs('#close_btn');

  let state = {
    serial: null,
    components: {}, // category => index (-1..max)
    schema: {},     // category => max index
    catalog: {},    // category => [componentName]
    price: {},      // category => number (legacy price)
    mats: {},       // materials mapping
    weapon: null,
  };

  function show(){ container.classList.remove('hidden'); }
  function hide(){ container.classList.add('hidden'); }

  function clampIndex(v, max){
    const n = Number(v);
    if (isNaN(n)) return -1;
    return Math.max(-1, Math.min(max, n));
  }

  function aggregateMaterials(){
    // state.mats format: { default: { CAT:[{item,amount}] }, perWeapon: { [weapon]: { CAT:[...] } } }
    const out = {};
    const def = (state.mats && state.mats.default) || {};
    const perW = (state.mats && state.mats.perWeapon && state.mats.perWeapon[state.weapon || '']) || {};
    Object.keys(state.components||{}).forEach(cat => {
      const idx = Number(state.components[cat] ?? -1);
      if (isNaN(idx) || idx < 0) return;
      const lst = (perW[cat] || def[cat] || []);
      lst.forEach(it => {
        if (!it || !it.item) return;
        const key = it.item; const n = Number(it.amount||0) || 0;
        if (n > 0) out[key] = (out[key]||0) + n;
      });
    });
    return out;
  }

  function materialsText(map){
    const entries = Object.keys(map).map(k => `${k} x${map[k]}`);
    return entries.length ? entries.join(', ') : 'None';
  }
  function materialsTextForList(list){
    if (!Array.isArray(list)) return '';
    const entries = list.map(it => `${it.item} x${it.amount}`);
    return entries.filter(Boolean).join(', ');
  }
  function catMaterialsArray(cat){
    const def = (state.mats && state.mats.default) || {};
    const perW = (state.mats && state.mats.perWeapon && state.mats.perWeapon[state.weapon || '']) || {};
    return perW[cat] || def[cat] || [];
  }
  function catMaterialsText(cat){
    const arr = catMaterialsArray(cat);
    return materialsTextForList(arr);
  }

  function setPriceText(){
    const mats = aggregateMaterials();
    if (priceLabel) priceLabel.textContent = `Required: ${materialsText(mats)}`;
  }

function section(title){
    const div = document.createElement('div');
    div.className = 'grid-item section';
    div.textContent = title;
    grid.appendChild(div);
  }

  function row(category){
    const has = Object.prototype.hasOwnProperty.call(state.schema, category);
    const max = has ? Number(state.schema[category] ?? 0) : -1;
    const el = document.createElement('div'); el.className = 'grid-item' + (has ? '' : ' disabled'); el.dataset.category = category;

    const labelBox = document.createElement('div'); labelBox.className = 'labelbox';
    const label = document.createElement('div'); label.className = 'label';
    const base = category.replace(/_/g, ' ');
    label.textContent = base;
    label.title = base;
    const req = catMaterialsText(category);
    if (req) { const sub = document.createElement('div'); sub.className = 'subnote'; sub.textContent = req; labelBox.appendChild(label); labelBox.appendChild(sub); }
    else { labelBox.appendChild(label); }
    const controls = document.createElement('div'); controls.className = 'controls';
    const left = document.createElement('div'); left.className = 'btn-left';
    const value = document.createElement('div'); value.className = 'row-value';
    const right = document.createElement('div'); right.className = 'btn-right';

    const current = clampIndex((state.components[category] != null) ? state.components[category] : -1, Math.max(max, 0));
    state.components[category] = current; value.textContent = has ? current : '—';

    function select(){
      fetch(`https://${resource}/camera`, { method: 'POST', body: JSON.stringify({ target: category }) });
    }

    if (has) {
      left.addEventListener('click', (ev)=>{
        ev.stopPropagation();
        const cur = clampIndex(value.textContent, max);
        const next = Math.max(-1, cur - 1);
        value.textContent = next;
        const prev = state.components[category];
        state.components[category] = next;
        fetch(`https://${resource}/preview`, { method: 'POST', body: JSON.stringify({ key: category, prev, value: next }) });
        setPriceText();
      });

      right.addEventListener('click', (ev)=>{
        ev.stopPropagation();
        const cur = clampIndex(value.textContent, max);
        const next = Math.min(max, cur + 1);
        value.textContent = next;
        const prev = state.components[category];
        state.components[category] = next;
        fetch(`https://${resource}/preview`, { method: 'POST', body: JSON.stringify({ key: category, prev, value: next }) });
        setPriceText();
      });

      el.addEventListener('click', select);
    }

    controls.appendChild(left); controls.appendChild(value); controls.appendChild(right);
    el.appendChild(labelBox); el.appendChild(controls);
    grid.appendChild(el);
  }

  function buildGrid(){
    grid.innerHTML = '';

    // Build grouped sections similar to BM, but number from 1 based on what exists
    const cats = (state.allcats && state.allcats.length) ? state.allcats : Object.keys(state.schema);
    const upgrade = [];
    const material = [];
    const engrPattern = [];
    const engrColours = [];

    cats.forEach(k => {
      if (/ENGRAVING_MATERIAL/.test(k)) { engrColours.push(k); return; }
      if (/CYLINDER_ENGRAVING/.test(k)) { engrPattern.push(k); return; }
      if (/ENGRAVING/.test(k)) { engrPattern.push(k); return; }
      if (/MATERIAL/.test(k)) { material.push(k); return; }
      upgrade.push(k);
    });

    const sections = [];
    if (upgrade.length) sections.push({ title: 'Upgrade', list: upgrade });
    if (material.length) sections.push({ title: 'Material', list: material });
    if (engrPattern.length) sections.push({ title: 'Engraving Pattern', list: engrPattern });
    if (engrColours.length) sections.push({ title: 'Engraving Colours', list: engrColours });

    sections.forEach((s, i) => {
      section(`#${i+1} ${s.title}`);
      s.list.forEach(row);
    });

    setPriceText();
  }

  // Pay & Save button (uses current indices)
  if (btnPay) {
    btnPay.addEventListener('click', ()=>{
      fetch(`https://${resource}/pay`, { method: 'POST', body: JSON.stringify({ components: state.components }) });
    });
  }

  // Close button
  if (closeBtn) {
    closeBtn.addEventListener('click', ()=>{
      fetch(`https://${resource}/exit`, { method: 'POST', body: '{}' });
    });
  }

  // Camera control buttons
  const camLeft = qs('#cam_left');
  const camRight = qs('#cam_right');
  const camUp = qs('#cam_up');
  const camDown = qs('#cam_down');
  const camZoomIn = qs('#cam_zoom_in');
  const camZoomOut = qs('#cam_zoom_out');
  if (camLeft) camLeft.addEventListener('click', ()=>{
    fetch(`https://${resource}/camera_pan`, { method: 'POST', body: JSON.stringify({ delta: -0.05 }) });
  });
  if (camRight) camRight.addEventListener('click', ()=>{
    fetch(`https://${resource}/camera_pan`, { method: 'POST', body: JSON.stringify({ delta: +0.05 }) });
  });
  if (camUp) camUp.addEventListener('click', ()=>{
    fetch(`https://${resource}/camera_tilt`, { method: 'POST', body: JSON.stringify({ delta: +0.02 }) });
  });
  if (camDown) camDown.addEventListener('click', ()=>{
    fetch(`https://${resource}/camera_tilt`, { method: 'POST', body: JSON.stringify({ delta: -0.02 }) });
  });
  if (camZoomIn) camZoomIn.addEventListener('click', ()=>{
    fetch(`https://${resource}/camera_zoom`, { method: 'POST', body: JSON.stringify({ delta: -0.05 }) });
  });
  if (camZoomOut) camZoomOut.addEventListener('click', ()=>{
    fetch(`https://${resource}/camera_zoom`, { method: 'POST', body: JSON.stringify({ delta: +0.05 }) });
  });

  // ESC/Backspace to exit mods panel
  window.addEventListener('keydown', (e)=>{
    if (e.key === 'Escape' || e.key === 'Backspace') {
      if (!document.getElementById('craftingUI').classList.contains('hidden')) {
        // close crafting overlay first
        fetch(`https://${resource}/closeCrafting`, { method: 'POST', body: '{}' });
      } else {
        fetch(`https://${resource}/exit`, { method: 'POST', body: '{}' });
      }
    }
  });

  // Crafting overlay bindings
  const craftClose = qs('#craft_close_btn');
  if (craftClose) craftClose.addEventListener('click', ()=>{
    fetch(`https://${resource}/closeCrafting`, { method: 'POST', body: '{}' });
  });

  // ---- Crafting state and helpers (from Bulletcraft UI) ----
  function safeSetTextContent(id, text){ const el=document.getElementById(id); if (el) el.textContent = text; }
  function getItemImagePath(name){ return `nui://rsg-inventory/html/images/${name}.png`; }

  const craftState = {
    crafting: [],
    inventory: {},
    rsgItems: {},
    activeCategory: null,
    selectedItem: null,
    lang: {},
    progressTimer: null,
    progressPct: 0,
  };

  function craftRenderCategories(){
    const list = document.getElementById('categoryList'); if (!list) return; list.innerHTML='';
    const cats = [...new Set((craftState.crafting||[]).map(i=>i.category))];
    cats.forEach(cat=>{ const b=document.createElement('button'); b.className='category-button'; b.textContent=cat; b.onclick=()=>{ craftState.activeCategory=cat; craftState.selectedItem=null; craftRenderItems(); craftRenderDetails(); }; list.appendChild(b); });
  }
  function craftRenderItems(){
    const grid = document.getElementById('itemGrid'); if (!grid) return; grid.innerHTML='';
    const items = (craftState.crafting||[]).filter(i=>!craftState.activeCategory || i.category===craftState.activeCategory);
    items.forEach(item=>{ const card=document.createElement('div'); card.className='item-card'; card.onclick=()=>{ craftState.selectedItem=item; craftRenderDetails(); };
      const img=document.createElement('img'); img.src=getItemImagePath(item.receive); img.onerror=function(){ this.src='https://hebbkx1anhila5yf.public.blob.vercel-storage.com/missing-Ei6BYYQtcjp52FZ3YCuAvRE2EtHc72.png'; }; img.alt=item.title||'Item'; img.className='item-image';
      const title=document.createElement('h3'); title.textContent=item.title||'Unknown Item';
      card.appendChild(img); card.appendChild(title); grid.appendChild(card);
    });
  }
  function asArrayMaybe(tbl){
    if (Array.isArray(tbl)) return tbl;
    if (tbl && typeof tbl === 'object') {
      // convert numeric-keyed object to array in ascending order
      return Object.keys(tbl).sort((a,b)=>Number(a)-Number(b)).map(k=>tbl[k]);
    }
    return [];
  }
  function craftRenderDetails(){
    const box = document.getElementById('itemDetails'); if (!box) return; box.innerHTML='';
    if (!craftState.selectedItem){ const p=document.createElement('p'); p.textContent=craftState.lang.select_item_to_view_details||'Select an item to view details'; box.appendChild(p); return; }
    const it = craftState.selectedItem;
    const btn=document.createElement('button'); btn.className='action-button'; btn.textContent=craftState.lang.craft||'Craft'; btn.onclick=()=>craftStart(it); box.appendChild(btn);
    const title=document.createElement('h3'); title.textContent=it.title||'Unknown Item'; box.appendChild(title);
    const img=document.createElement('img'); img.src=getItemImagePath(it.receive); img.onerror=function(){ this.src='https://hebbkx1anhila5yf.public.blob.vercel-storage.com/missing-Ei6BYYQtcjp52FZ3YCuAvRE2EtHc72.png'; }; img.alt=it.title||'Item'; img.className='item-image'; box.appendChild(img);
    const h4=document.createElement('h4'); h4.textContent=craftState.lang.required_items||'Required Items'; box.appendChild(h4);
    const ul=document.createElement('ul'); ul.className='ingredient-list';
    asArrayMaybe(it.ingredients).forEach(ing=>{
      const li=document.createElement('li'); li.className='ingredient-item';
      const im=document.createElement('img'); im.src=getItemImagePath(ing.item); im.onerror=function(){ this.src='https://hebbkx1anhila5yf.public.blob.vercel-storage.com/missing-Ei6BYYQtcjp52FZ3YCuAvRE2EtHc72.png'; }; im.alt=ing.item; im.className='ingredient-image';
      const span=document.createElement('span'); const have=craftState.inventory[ing.item]||0; const label=(craftState.rsgItems && craftState.rsgItems[ing.item] && craftState.rsgItems[ing.item].label) || ing.item; span.textContent=`${label}: ${ing.amount} ${craftState.lang.needed||'needed'} / ${have} ${craftState.lang.you_have||'you have'}`;
      li.appendChild(im); li.appendChild(span); ul.appendChild(li);
    });
    box.appendChild(ul);
  }
  function craftStart(item){
    fetch(`https://${resource}/startCrafting`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ actionType: craftState.lang.crafting||'Crafting', name: item.title, receive: item.receive, ingredients: item.ingredients, giveamount: item.giveamount, crafttime: item.crafttime }) })
      .then(r=>r.json()).catch(()=>{});
  }
  function craftShow(){ document.getElementById('craftingUI').classList.remove('hidden'); }
  function craftHide(){ document.getElementById('craftingUI').classList.add('hidden'); }
  function craftStartProgress(duration, action){
    // Small inline progress UI (reuse of bulletcraft)
    const existing=document.querySelector('.progress-popup'); if(existing) existing.remove();
    const pop=document.createElement('div'); pop.className='progress-popup';
    const title=document.createElement('h3'); title.textContent=`${action} ${craftState.lang.in_progress||'in progress'}...`; pop.appendChild(title);
    const bar=document.createElement('div'); bar.className='progress-bar'; const fill=document.createElement('div'); fill.className='progress-bar-fill'; bar.appendChild(fill); pop.appendChild(bar);
    const cancel=document.createElement('button'); cancel.className='cancel-button'; cancel.textContent=craftState.lang.cancel||'Cancel'; pop.appendChild(cancel);
    document.getElementById('craftingUI').appendChild(pop);
    craftState.progressPct=0; if(craftState.progressTimer) clearInterval(craftState.progressTimer);
    craftState.progressTimer=setInterval(()=>{ craftState.progressPct += (100/(duration/1000)); if(craftState.progressPct>=100){ craftState.progressPct=100; clearInterval(craftState.progressTimer); const ex=document.querySelector('.progress-popup'); if(ex) ex.remove(); } fill.style.width = `${craftState.progressPct}%`; if(craftState.progressPct>=80){ cancel.style.display='none'; } },1000);
    cancel.onclick=()=>{ if(craftState.progressPct<80){ clearInterval(craftState.progressTimer); const ex=document.querySelector('.progress-popup'); if(ex) ex.remove(); fetch(`https://${resource}/cancelCrafting`, { method:'POST', body:'{}' }); } };
  }

  window.addEventListener('message', (e)=>{
    const data = e.data || {};
    if (data.type === 'open') {
      state.serial = data.serial || null;
      state.schema = data.schema || {};
      state.catalog = data.catalog || {};
      state.price = data.price || {};
      state.mats = data.materials || {};
      state.weapon = data.weapon || null;
      state.allcats = data.allcats || [];
      const indices = data.indices || {};
      state.components = {};
      Object.keys(state.schema).forEach((k)=>{
        const max = Number(state.schema[k] ?? 0);
        const idx = (typeof indices[k] === 'number') ? indices[k] : -1;
        state.components[k] = clampIndex(idx, max);
      });
      buildGrid();
      show();
    } else if (data.type === 'close') {
      hide();
    } else if (data.type === 'saved') {
      setPriceText();
    } else if (data.type === 'craft:open') {
      craftState.crafting = data.crafting || [];
      craftState.inventory = data.inventory || {};
      craftState.rsgItems = data.items || {};
      craftState.lang = data.lang || {};
      craftShow();
      safeSetTextContent('categoriesTitle', craftState.lang.categories || 'Categories');
      safeSetTextContent('itemsTitle', craftState.lang.craftable_items || 'Craftable Items');
      safeSetTextContent('detailsTitle', craftState.lang.item_details || 'Item Details');
      craftRenderCategories();
      craftRenderItems();
      craftRenderDetails();
    } else if (data.type === 'craft:close') {
      craftHide();
    } else if (data.type === 'craft:startProgress') {
      craftStartProgress(data.duration, data.actionType || 'Crafting');
    } else if (data.type === 'craft:showMissing') {
      // Minimal missing items popup
      alert('Missing items. Check ingredients.');
    }
  });
})();
