-- ============================================================
-- 函数名称: SetupClipboard
-- 功能描述: 根据当前运行环境（SSH 远程 或 本地）自动配置剪贴板
-- ============================================================
local function SetupClipboard()
  -- 探测是否处于 SSH 远程连接环境
  if vim.env.SSH_TTY then
    -- 🟢 远程模式：注入 OSC 52 隧道同步逻辑
    vim.g.clipboard = {
      name = 'OSC52',
      copy = {
        ['+'] = function(lines)
          local s = table.concat(lines, '\n')
          local base64 = vim.fn.system('base64 | tr -d "\n"', s)
          vim.fn.chansend(vim.v.stderr, '\27]52;c;' .. base64 .. '\7')
        end,
        ['*'] = function(lines)
          local s = table.concat(lines, '\n')
          local base64 = vim.fn.system('base64 | tr -d "\n"', s)
          vim.fn.chansend(vim.v.stderr, '\27]52;c;' .. base64 .. '\7')
        end,
      },
      paste = {
        ['+'] = function() return { vim.fn.getreg '+', vim.fn.getregtype '+' } end,
        ['*'] = function() return { vim.fn.getreg '*', vim.fn.getregtype '*' } end,
      },
    }
  else
    -- 🔵 本地模式：调用系统原生 Provider (如 Mac 的 pbcopy 或 Linux 的 xclip)
    vim.o.clipboard = 'unnamedplus'
  end
end

-- 立即执行函数
SetupClipboard()
