--
-- vim: set shiftwidth=2 tabstop=2 expandtab:
--
-- title:  Overnight Janitor
-- author: lzap
-- desc:   Inspired by a minigame from funcade.
-- script: lua
--
t=0 -- tick tracker
total=999 -- total game time until game over
mn=1 -- current level number
mx=0 -- current map x cell
my=0 -- current map y cell
hx=-1 -- head position x
hy=-1 -- head position y
tb=-1 -- blink border until time
hint=nil -- hud hint text
hintWidth=0
hintStarted=-1 -- hint message time
timeWidth=0

function BOOT()
  timeWidth = print("T999", 0, -6)
  startHint(2500, "Push arrows, time is ticking!")
end

-- find map tile flag ignoring the first row
function flagAt(x, y, flag)
  local id = mget(x * 2, 1 + y * 2)
  return fget(id, flag), id
end

-- find starting head position via sprite flags
function spritePos(flag)
  for x = mx//2, mx//2 + 15 do
    for y = my//2, my//2 + 8 do
      local flag, id = flagAt(x, y, flag)
      if flag then
        return x, y
      end
    end
  end
  trace("sprite not found!")
  exit()
end

-- when floor is all clear
function levelDone()
  for x = mx//2, mx//2 + 15 do
    for y = my//2, my//2  +8 do
      local flag = flagAt(x, y, 2)
      if flag then return false end
    end
  end
  return true
end

function startHint(ms,msg)
  hint=msg
  hintWidth = print(hint, 0, -6)
  hintStarted = time()+ms
end

function moveh(dx,dy)
  nx=hx-dx
  ny=hy-dy
  if flagAt(nx, ny, 7) then
    -- wall hit
    sfx(1, 30, 15, 3, 7)
    startHint(1500, "Press [X] or [B] to try again")
  else
    -- movement - change map for current
    sfx(0, 70, 15, 3, 15)
    mset(0 + hx * 2, 1 + 0 + hy * 2, 4)
    mset(0 + hx * 2, 1 + 1 + hy * 2, 20)
    mset(1 + hx * 2, 1 + 0 + hy * 2, 5)
    mset(1 + hx * 2, 1 + 1 + hy * 2, 21)
    hx=nx
    hy=ny
    -- and the new position
    mset(0 + hx * 2, 1 + 0 + hy * 2, 4)
    mset(0 + hx * 2, 1 + 1 + hy * 2, 20)
    mset(1 + hx * 2, 1 + 0 + hy * 2, 5)
    mset(1 + hx * 2, 1 + 1 + hy * 2, 21)
  end
  --trace("head at hx="..nx.." hy="..ny.." x="..(hx % 15 * 16).." y="..(hy % 8 * 16))
end

function resetLevel()
  sfx(2, 50, 30, 3, 8)
  hx=-1
  hy=-1
  hint=nil
  hintStarted=-1
  -- throw away all map changes
  sync(0, 0, false)
end

function nextLevel()
  mn=mn+1
  mx=mx+30
  resetLevel()
end

function hintTIC()
  local tm=time()
  if tm > hintStarted then
    hintStarted=-1
    hint = ""
    hintWidth = 0
  else
    print(hint, (240 - hintWidth) // 2, 0, (tm%3)+2)
  end
end

function hudTIC()
  print("L"..mn, 0, 0, 12)
  print("T"..math.floor(total-time() // 1000), 240 - timeWidth, 0, 12)
end

function TIC()
  cls(0)
  map(mx, my)
  if hx == -1 then
    hx, hy = spritePos(0)
  end
  if hx == nil or hy == nil then
    trace("starting position not found!")
    exit()
  end
  if btnp(0,60,6) then moveh(0,1) end
  if btnp(1,60,6) then moveh(0,-1) end
  if btnp(2,60,6) then moveh(1,0) end
  if btnp(3,60,6) then moveh(-1,0) end
  if btnp(5,60,6) then resetLevel() end
  -- draw head
  spr(256 + 2*(t % 120 // 30), hx % 15 * 16, (hy % 8 * 16) + 8, -1, 1, 0, 0, 2, 2)
  -- level done
  --if flagAt(hx,hy,1) then
  if levelDone() then
    nextLevel()
  end
  hudTIC()
  hintTIC()
  t = t + 1
end

-- <TILES>
-- 002:000000000222222202f2222202222ff202222222022ff2220222222f02222f22
-- 003:000000002222222022f222202222ff20222222202ffff2202222222022ff2220
-- 004:000000000ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc
-- 005:00000000ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0
-- 006:000000000eeeeeee0eeeeeee0eeeeeef0eeeeeee0eeeeeee0eeffffe0eeeeeee
-- 007:00000000eeeeeee0eeeeeee0eeeeeee0eeeeffe0eeeeeee0eeeeeee0eeeeeee0
-- 008:000000000eeeeeee0eefeeee0eeeeeee0eeeeeee0eeeeeee0eefffee0eeeeeee
-- 009:00000000eeeeeee0eeeeeee0effffee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0
-- 018:02f22222022222220222fff20222222202f222220222ff220222222200000000
-- 019:222222202f2222202222ff2022f222202222222022222ff02222222000000000
-- 020:0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc00000000
-- 021:ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc000000000
-- 022:0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeffffe0eeeeeee0eeeeeee00000000
-- 023:eeeeeee0eefffee0eeeeeee0eeeeeee0eeeeeee0eeeefee0eeeeeee000000000
-- 024:0eeeeeee0eeeeeee0eeeeeee0effeeee0eeeeeee0eeeeeee0eeeeeee00000000
-- 025:eeeeeee0effffee0eeeeeee0eeeeeee0feeeeee0eeeeeee0eeeeeee000000000
-- 032:000000000eeeeeee0eeeeeee0eeeeeee0eee99990eee99990eee99920eee9992
-- 033:00000000eeeeeee0eeeeeee0eeeeeee09999eee09999eee02999eee02999eee0
-- 034:00000000022222220ff222220222222202222f2202ff2222022222f202222222
-- 035:000000002222222022ff222022222f20222222202fff22202222222022222f20
-- 048:0eee99960eee99960eee99990eee99990eeeeeee0eeeeeee0eeeeeee00000000
-- 049:6999eee06999eee09999eee09999eee0eeeeeee0eeeeeee0eeeeeee000000000
-- 050:0222ff2202222222022ffff20222222202ff222202222f220222222200000000
-- 051:22f22220f2222220222ff220222222202ff2222022222f202222222000000000
-- 066:0000000000000000000000000000000000000000000000000000000002222222
-- 067:0000000000000000000000000000000000000000000000000000000022222220
-- 082:02f22222022222220222fff20222222202f222220222ff220222222200000000
-- 083:222222202f2222202222ff2022f222202222222022222ff02222222000000000
-- 240:000000000000000000000000000cc000000cccc00000c0c00000ccc000000000
-- </TILES>

-- <SPRITES>
-- 000:000000000eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeef0eeeeeef0eeeeeff
-- 001:00000000effffee0eea4aee0ee444ee0fee4eee0fee3eee04e33eee0434434e0
-- 002:000000000eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeef0eeeeeff0eeeeef4
-- 003:00000000effffee0eea4aee0ee444ee0fee4eee0fee3eee04e33eee0444434e0
-- 004:000000000eeffffe0eea4aee0ee444ee0eee4eef0eee3eef0eee33e40e434434
-- 005:00000000eeeeeee0eeeeeee0eeeeeee0eeeeeee0feeeeee0feeeeee0ffeeeee0
-- 006:000000000eeffffe0eea4aee0ee444ee0eee4eef0eee3eef0eee33e40e434444
-- 007:00000000eeeeeee0eeeeeee0eeeeeee0eeeeeee0feeeeee0ffeeeee04feeeee0
-- 016:0eeeeefe0eeeeffe0eeeefee0eefccee0eecccce0eefcfee0eeeeeee00000000
-- 017:e33344e0e3333ee066e66ee0e6ee6ee0e6ee6ee044e44ee0eeeeeee000000000
-- 018:0eeeefee0eeeffee0eeefeee0efcceee0eccccee0efcfeee0eeeeeee00000000
-- 019:e33344e0e3333ee066e66ee0e6ee6ee0e6ee6ee044e44ee0eeeeeee000000000
-- 020:0e44333e0ee3333e0ee66e660ee6ee6e0ee6ee6e0ee44e440eeeeeee00000000
-- 021:efeeeee0effeeee0eefeeee0eeccfee0eccccee0eefcfee0eeeeeee000000000
-- 022:0e44333e0ee3333e0ee66e660ee6ee6e0ee6ee6e0ee44e440eeeeeee00000000
-- 023:eefeeee0eeffeee0eeefeee0eeeccfe0eecccce0eeefcfe0eeeeeee000000000
-- </SPRITES>

-- <MAP>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000100010001000100010001000100010001000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000011101110111011101110111011101110111011101110111000000000000000000000000000000000000000000000000000000000000000000000000000000000024342434243424342434000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025352535253525352535000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000243420302434000000000000000000002434243424342434243424342434243424342434243400000000000000000000000000000000000000002434243424340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020306070607060702030243424340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000253521312535000000000000000000002535253525352535253525352535253525352535253500000000000000000000000000000000000000002535253525350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021316171617161712131253525350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011100000000000000000000000000000000000000
-- 005:000000000111203020302030203022322232223220302030000000000000000000000000203020302030243400100000203020302030243400000000000000002232223220302030203020302030203020302030223200000000000000000000000000100010203020302232223222320000000000000000000000000000203020302030203020302232223222322434000000000000000000000000000020306070203002122030203020300000000000000000000000000000000000002232223222322232223200000000000000000000000000000010203020302030203020302030203020302030000000000000
-- 006:000000000000213121312131213123332333233321312131001000100010000000000000213121312131253501110101213121312131253500000000000000002333233321312131213121312131213121312131233300000000000000000000000001110111213121312333233323330000000000000000000000000000213121312131213121312333233323332535000000000000000000000000000021316171213103132131213121310000000000000000000000000000000000002333233323332333233300000000000000000000000000000011213121312131213121312131213121312131000000000000
-- 007:000000000000203002126070607060706070607060702030011101110111000000000000203002122030223220302434223260702030203000000000000000002030607060706070021220306070607060706070223200000000000000000000000000002030203060706070203020300000000000000000000000000000203060706070607060706070607020302030000000000000000000000000000020306070607060706070607020300000000000000000000000000000000000002232021260706070223200000000000000000000000000000000203002126070607060706070607060702030000000000000
-- 008:000000000000213103136171617161716171617161712131001000100010000000000000213103132131233321312535233361712131213100000000000000002131617161716171031321316171617161716171233300000000000000000000000000002131213161716171213121310000000000000000000000000000213161716171617161716171617121312131000000000000000000000000000021316171617161716171617121310000000000000000000000000000000000002333031361716171233300000000000000000000000000000000213103136171617161716171617161712131010000000000
-- 009:000000000000203020302030223220302030223260702030011101110111000000000000203060706070607020302030203060702232223200000000000000002030607020302232223222322232203020306070203000000000000000000000000022322232607060706070223220300000000000000000000000000000203060702030607060702232607020302232000000000000000000000000000020302030203060702030607020300000000000000000000000000000000000002232607080902232223200000000000000000000000000000000203022326070607060706070607060702030000000000000
-- 010:000000000010213121312131233321312131233361712131101000100010000000000000213161716171617121312131213161712333233300000000000000002131617121312333233323332333213121316171213100000000000000000000000023332333617161716171233321310000000000000000000000000000213161712131617161712333617121312333000000000000000000000000000021312131213161712131617121310000000000000000000000000000000000002333617181912333233300000000000000000000000000000000213123336171617161716171617161712131010000000000
-- 011:000000000111000000000000000000000000223260702030111101110111000000000000203020302030607060706070607060702030203000000000000000002030607060706070607060706070607060706070203000000000000000000000000020300212607060706070223220300000000000000000000000000000203060706070607060706070607002122030000000000000000000000000000000000000203060706070607020300000000000000000000000000000000000002232223222322232000000000000000000000000000000000010203020302030203020302030203020302030100000000000
-- 012:000000000000000000000000000000000000233361712131000000000000000000000000213121312131617161716171617161712131213100000000000000002131617161716171617161716171617161716171213100000000000000000000000021310313617161716171233321310000000000000000000000000000213161716171617161716171617103132131000000000000000000000000000000000000213161716171617121310000000000000000000000000000000000002333233323332333000000000000000000000000000000000011213121312131213121312131213121312131110000000000
-- 013:000000000000000000000000000000000000203020302030000000000000000000000000000000002030223222322030203022322232001000000000000000002030223222322030203020302232223220302232223200000000000000000000000022322232203020302030223220300000000000000000000000000000223222322232203020302030223222322232000000000000000000000000000000000000203020302030203020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100010001010000000000000
-- 014:000000000000000000000000000000000000213121312131000000000000000000000000000000002131233323332131213123332333001100000000000000002131233323332131213121312333233321312333233300000000000000000000000023332333213121312131233321310000000000000000000000000000233323332333213121312131233323332333000000000000000000000000000000000000213121312131213121310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:000000000000000000000000000000000000000000000000000000000000000000000000000024342434243424342434243424340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024342434243400000000000000000000000000000000000000000000243424342434243400000000000000000000000000000000000000243424342434243424342434243400000000000000000000000000000024342434243424342434000000000000000000000000
-- 019:000000000000000000000000000000000000000000000000000000000000000000000000000025352535253525352535253525350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025352535253500000000000000000000000000000000000000002030253525352535253500000000000000000000000000000000000000253525352535253525352535253500000000000000000000000000000025352535253525352535000000000000000000000000
-- 020:000000000000203020302232223200000000000000000000000000000000000000000000000022326070607022326070607022320000000000000000000000000000000000002434243424342434243400000000000000000000000000000000000000000000000024342232223222322232000000000000000000000000000000000000000022320212203000000000000000000000000000000000000000002030607060706070223200000000000000000000000000000000002232223222328090809080902232223200000000000000000000000000000020306070607060702030203020300000000000000000
-- 021:000000000000213121312333233300000000000000000000000000000000000000000000000023336171617123336171617123330000000000000000000000000000000000002535253525352535253500000000000000000000000000000000000000000000000025352333233323332333000000000000000000000000000000000000000023330313213100000000000000000000000000000000000000002131617161716171233300000000000000000000000000000000002333233323338191819181912333233300000000000000000000000000000021316171617161712131213121310000000000000000
-- 022:000000000000223260706070223220302030223222322232000000000000000000000000000022320212607060706070607022320000000000000000000000000000000000002030203020302030203000000000000000000000000000000000243420302232223220302232809080902030000000000000000000000000000000000000000022326070203000000000000000000000000000000000000020302030607020306070223200000000000000000000000000000000002232819180908090809080902232223200000000000000000000000000000020306070203060706070203020300000000000000000
-- 023:000000000000233361716171233321312131233323332333000000000000000000000000000023330313617161716171617123330000000000000000000000000000000000002131213121312131213100000000000000000000000000000000253521312333233321312333819181912131000000000000000000000000000000000000000023336171213100000000000000000000000000000000000021312131617121316171233300000000000000000000000000000000002333819181918191819181912333233300000000000000000000000000000021316171213161716171213121310000000000000000
-- 024:000000000000223202126070607060706070607060702030000000000000000000000000000022322232607060702232323222320000000000000000000000000000000000002030809080908090203000000000000000000000000000000000203022322232809080908090809080902030000000000000000000000000000000002030223222326070223200000000000000000000000000000000000022326070607060706070607020302232000000000000000000000000002232809022322232809002122232223200000000000000000000000000000020306070607060706070607020300000000000000000
-- 025:000000000000233303136171617161716171617161712131000000000000000000000000000023332333617161712333333323330000000000000000000000000000000000002131819181918191213100000000000000000000000000000000213123332333819181918191819181912131000000000000000000000000000000002131233323336171233300000000000000000000000000000000000023336171617161716171617121312333000000000000000000000000002333819123332333819103132333233300000000000000000000000000000021316171617160706171617121310000000000000000
-- 026:000000000000223220302030607020306070607060702232000000000000000000000000000022322232607060706070223222320000000000000000000000000000000000002030809002128090203000000000000000000000000000000000203080908090809080908090809080902030000000000000000000000000000020302232607060706070607020300000000000000000000000000000000022326070021260702232607020302232000000000000000000000000002232809022322232809080902232223200000000000000000000000000000020306070607002122030607020300000000000000000
-- 027:000000000000233321312131617121316171617161712333000000000000000000000000000023332333617161716171233323330000000000000000000000000000000000002131819103138191213100000000000000000000000000000000213181918191819181918191819181912131000000000000000000000000000021312333617161716171617121310000000000000000000000000000000023336171031361712333617121312333000000000000000000000000002333819123332333819181912333233300000000000000000000000000000021316171617103132131617121310000000000000000
-- 028:000000000000000000002232607060706070203020302232000000000000000000000000000000002232607060706070223200000000000000000000000000000000000000002030809080908090203000000000000000000000000000000000203022320212809080902232809080902232000000000000000000000000000020302030223260706070607020300000000000000000000000000000000020306070607060706070607022322232000000000000000000000000002232809080908090809080902232223200000000000000000000000000000020306070607060706070607020300000000000000000
-- 029:000000000000000000002333617161716171213121312333000000000000000000000000000000002333617161716171233300000000000000000000000000000000000000002131819181918191213100000000000000000000000000000000213123330313819181912333819181912333000000000000000000000000000021312131233361716171617121310000000000000000000000000000000021316171617161716171617123332333000000000000000000000000002333819181918191819181912333233300000000000000000000000000000021316171617161716171617121310000000000000000
-- 030:000000000000000000002232203022322232223200000000000000000000000000000000000000002232223222322232223200000000000000000000000000000000000000002030203020302030203000000000000000000000000000000000203022322232223222322232223222322232000000000000000000000000000000000000223222322232223222320000000000000000000000000000000020302030223222322232203020300000000000000000000000000000002232223222322232223222322232223200000000000000000000000000000020302030203020302030203020300000000000000000
-- 031:000000000000000000002333213123332333233300000000000000000000000000000000000000002333233323332333233300000000000000000000000000000000000000002131213121312131213100000000000000000000000000000000213123332333233323332333233323332333000000000000000000000000000000000000233323332333233323330000000000000000000000000000000021312131233323332333213121310000000000000000000000000000002333233323332333233323332333233300000000000000000000000000000021312131213121312131213121310000000000000000
-- 035:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024342434243424342434243424340000000000000000000000000000000000002434243424342434243424340000000000000000000000000000000000000024342434243424340000000000000000000000000000000000000000000000243424342434243424340000000000000000000000000000000000002434243424342434243424340000000000000000000000000000000024342434243424342434243424342434000000000000
-- 036:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025352535253525352535253525350000000000000000000000000000000000002535253525352535253525350000000000000000000000000000000000000025352535253525350000000000000000000000000000000000000000000000253525352535253525350000000000000000000000000000000000002535253525352535253525350000000000000000000000000000000025352535253525352535253525352535000000000000
-- 037:000000000000000022322232223222322232223200000000000000000000000000000000000022322232223222322232223222320000000000000000000000000000000022328090809080908090809022320000000000000000000000000000000022322030203080908090809022320000000000000000000000000000002030203060706070607020302434223200000000000000000000000000000020302030607060706070607020300000000000000000000000000000000024342232607060706070607022320000000000000000000000000000000022326070607060706070607022322232000000000000
-- 038:000000000000000023332333233323332333233300000000000000000000000000000000000023332333233323332333233323330000000000000000000000000000000023338191819181918191819123330000000000000000000000000000000023332131213181918191819123330000000000000000000000000000002131213161716171617121312535233300000000000000000000000000000021312131617161716171617121310000000000000000000000000000000025352333617161716171617123330000000000000000000000000000000023336171617161716171617123332333000000000000
-- 039:000000000000000022328090809080902232223222320000000000000000000000000000000022328090809080908090809022320000000000000000000000000000000022328090809080902232809022320000000000000000000000000000000022326070809080902030809020300000000000000000000000000000002030607060706070021220302030223200000000000000000000000000000020306070607060700212607020300000000000000000000000000000000022322232607022322232607022320000000000000000000000000000000022326070223260700212607022322232000000000000
-- 040:000000000000000023338191819181912333233323330000000000000000000000000000000023338191819181918191819123330000000000000000000000000000000023338191819181912333819123330000000000000000000000000000000023336171819181912131819121310000000000000000000000000000002131617161716171031321312131233300000000000000000000000000000021316171617161710313617121310000000000000000000000000000000023332333617123332333617123330000000000000000000000000000000023336171233361710313617123332333000000000000
-- 041:000000000000000022328090223280908090223222320000000000000000000000000000000022328090223222322232809022320000000000000000000000000000000022328090809080908090809022320000000000000000000000000000000022322030607080908090809022320000000000000000000000000000002030607020306070607060702030223200000000000000000000000000000020306070203060706070607020300000000000000000000000000000000022322232607060706070607022320000000000000000000000000000000022326070223260702232607022322232000000000000
-- 042:000000000000000023338191233381918191233323330000000000000000000000000000000023338191233323332333819123330000000000000000000000000000000023338191819181918191819123330000000000000000000000000000000023332131617181918191819123330000000000000000000000000000002131617121316171617161712131233300000000000000000000000000000021316171213161716171617121310000000000000000000000000000000023332333617161716171617123330000000000000000000000000000000023336171233361712333617123332333000000000000
-- 043:000000000000000022328090809080908090223222320000000000000000000000000000000022328090809080908090809022320000000000000000000000000000000022328090809002122232809022320000000000000000000000000000000022322030809002128090809022320000000000000000000000000000002030607060706070203060702030223200000000000000000000000000000020306070607020306070203020300000000000000000000000000000000022322232607002122232607022320000000000000000000000000000000022326070607060706070607022320000000000000000
-- 044:000000000000000023338191819181918191233323330000000000000000000000000000000023338191819181918191819123330000000000000000000000000000000023338191819103132333819123330000000000000000000000000000000023332131819103138191819123330000000000000000000000000000002131617161716171213161712131233300000000000000000000000000000021316171617121316171213121310000000000000000000000000000000023332333617103132333617123330000000000000000000000000000000023336171617161716171617123330000000000000000
-- 045:000000000000000022328090021280908090223222320000000000000000000000000000000022328090809002128090809022320000000000000000000000000000000022328090809080908090809022320000000000000000000000000000000022322030809080908090607022320000000000000000000000000000002030203020306070607060702030223200000000000000000000000000000020302030607060706070203000000000000000000000000000000000000022322232607060706070607022320000000000000000000000000000000022322232607060702232223222320000000000000010
-- 046:000000000000000023338191031381918191233322320000000000000000000000000000000023338191819103138191819123330000000000000000000000000000000023338191819181918191819123330000000000000000000000000000000023332131819181918191617123330000000000000000000000000000002131213121316171617161712131233300000000000000000000000000000021312131617161716171213100000000000000000000000000000000000023332333617161716171617123330000000000000000000000000000000023332333617161712333233323330000000000000111
-- 047:000000000000000022322232223222322232223222320000000000000000000000000000000022322232223222322232223222320000000000000000000000000000000022322232223222322232223222320000000000000000000000000000000022322030223222322232203020300000000000000000000000000000002030203020302030203020302030223200000000000000000000000000000000002030203020302030203000000000000000000000000000000000000022322232223222322232223222320000000000000000000000000000000000002232223222322232000000000000000000000010
-- 048:000000000000000023332333233323332333233323330000000000000000000000000000000023332333233323332333233323330000000000000000000000000000000023332333233323332333233323330000000000000000000000000000000023332131233323332333213121310000000000000000000000000000002131213121312131213121312131233300000000000000000000000000000000002131213121312131213100000000000000000000000000000000000023332333233323332333233323330000000000000000000000000000000000002333233323332333000000000000000000000111
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:edca877644322211111111233455689b
-- </WAVES>

-- <SFX>
-- 000:1309030b030d330f9301d304f306f307f307f307f307f307f307f307f307f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300d04000000000
-- 001:00070003000f000e000c500ab008f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000109000000000
-- 002:5200220002000200020302030203020302050205020502050207020702070207020722075207a207f200f200f200f200f200f200f200f200f200f200c05000000000
-- </SFX>

-- <FLAGS>
-- 000:00000808080840404040000000000000000008080808404040400000000000001010080800000000000000000000000010100808000000000000000000000000000008080000000000000000000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

