{.passC: staticExec("pkg-config --cflags libproc2").}
{.passL: staticExec("pkg-config --libs   libproc2").}

# Translated using c2nim
#
# meminfo.h - memory related declarations for libproc2
#
# Copyright © 2015-2023 Jim Warner <james.warner@comcast.net>
# Copyright © 2015-2023 Craig Small <csmall@dropbear.xyz>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

type MeminfoItem* {.size: sizeof(cint).} = enum
  MEMINFO_noop
  MEMINFO_extra
  MEMINFO_MEM_ACTIVE
  MEMINFO_MEM_ACTIVE_ANON
  MEMINFO_MEM_ACTIVE_FILE
  MEMINFO_MEM_ANON
  MEMINFO_MEM_AVAILABLE
  MEMINFO_MEM_BOUNCE
  MEMINFO_MEM_BUFFERS
  MEMINFO_MEM_CACHED
  MEMINFO_MEM_CACHED_ALL
  MEMINFO_MEM_CMA_FREE
  MEMINFO_MEM_CMA_TOTAL
  MEMINFO_MEM_COMMITTED_AS
  MEMINFO_MEM_COMMIT_LIMIT
  MEMINFO_MEM_DIRECTMAP_1G
  MEMINFO_MEM_DIRECTMAP_2M
  MEMINFO_MEM_DIRECTMAP_4K
  MEMINFO_MEM_DIRECTMAP_4M
  MEMINFO_MEM_DIRTY
  MEMINFO_MEM_FILE_HUGEPAGES
  MEMINFO_MEM_FILE_PMDMAPPED
  MEMINFO_MEM_FREE
  MEMINFO_MEM_HARD_CORRUPTED
  MEMINFO_MEM_HIGH_FREE
  MEMINFO_MEM_HIGH_TOTAL
  MEMINFO_MEM_HIGH_USED
  MEMINFO_MEM_HUGETBL
  MEMINFO_MEM_HUGE_ANON
  MEMINFO_MEM_HUGE_FREE
  MEMINFO_MEM_HUGE_RSVD
  MEMINFO_MEM_HUGE_SIZE
  MEMINFO_MEM_HUGE_SURPLUS
  MEMINFO_MEM_HUGE_TOTAL
  MEMINFO_MEM_INACTIVE
  MEMINFO_MEM_INACTIVE_ANON
  MEMINFO_MEM_INACTIVE_FILE
  MEMINFO_MEM_KERNEL_RECLAIM
  MEMINFO_MEM_KERNEL_STACK
  MEMINFO_MEM_LOCKED
  MEMINFO_MEM_LOW_FREE
  MEMINFO_MEM_LOW_TOTAL
  MEMINFO_MEM_LOW_USED
  MEMINFO_MEM_MAPPED
  MEMINFO_MEM_MAP_COPY
  MEMINFO_MEM_NFS_UNSTABLE
  MEMINFO_MEM_PAGE_TABLES
  MEMINFO_MEM_PAGE_TABLES_SEC
  MEMINFO_MEM_PER_CPU
  MEMINFO_MEM_SHADOWCALLSTACK
  MEMINFO_MEM_SHARED
  MEMINFO_MEM_SHMEM_HUGE
  MEMINFO_MEM_SHMEM_HUGE_MAP
  MEMINFO_MEM_SLAB
  MEMINFO_MEM_SLAB_RECLAIM
  MEMINFO_MEM_SLAB_UNRECLAIM
  MEMINFO_MEM_TOTAL
  MEMINFO_MEM_UNACCEPTED
  MEMINFO_MEM_UNEVICTABLE
  MEMINFO_MEM_USED
  MEMINFO_MEM_VM_ALLOC_CHUNK
  MEMINFO_MEM_VM_ALLOC_TOTAL
  MEMINFO_MEM_VM_ALLOC_USED
  MEMINFO_MEM_WRITEBACK
  MEMINFO_MEM_WRITEBACK_TMP
  MEMINFO_MEM_ZSWAP
  MEMINFO_MEM_ZSWAPPED
  MEMINFO_DELTA_ACTIVE
  MEMINFO_DELTA_ACTIVE_ANON
  MEMINFO_DELTA_ACTIVE_FILE
  MEMINFO_DELTA_ANON
  MEMINFO_DELTA_AVAILABLE
  MEMINFO_DELTA_BOUNCE
  MEMINFO_DELTA_BUFFERS
  MEMINFO_DELTA_CACHED
  MEMINFO_DELTA_CACHED_ALL
  MEMINFO_DELTA_CMA_FREE
  MEMINFO_DELTA_CMA_TOTAL
  MEMINFO_DELTA_COMMITTED_AS
  MEMINFO_DELTA_COMMIT_LIMIT
  MEMINFO_DELTA_DIRECTMAP_1G
  MEMINFO_DELTA_DIRECTMAP_2M
  MEMINFO_DELTA_DIRECTMAP_4K
  MEMINFO_DELTA_DIRECTMAP_4M
  MEMINFO_DELTA_DIRTY
  MEMINFO_DELTA_FILE_HUGEPAGES
  MEMINFO_DELTA_FILE_PMDMAPPED
  MEMINFO_DELTA_FREE
  MEMINFO_DELTA_HARD_CORRUPTED
  MEMINFO_DELTA_HIGH_FREE
  MEMINFO_DELTA_HIGH_TOTAL
  MEMINFO_DELTA_HIGH_USED
  MEMINFO_DELTA_HUGETBL
  MEMINFO_DELTA_HUGE_ANON
  MEMINFO_DELTA_HUGE_FREE
  MEMINFO_DELTA_HUGE_RSVD
  MEMINFO_DELTA_HUGE_SIZE
  MEMINFO_DELTA_HUGE_SURPLUS
  MEMINFO_DELTA_HUGE_TOTAL
  MEMINFO_DELTA_INACTIVE
  MEMINFO_DELTA_INACTIVE_ANON
  MEMINFO_DELTA_INACTIVE_FILE
  MEMINFO_DELTA_KERNEL_RECLAIM
  MEMINFO_DELTA_KERNEL_STACK
  MEMINFO_DELTA_LOCKED
  MEMINFO_DELTA_LOW_FREE
  MEMINFO_DELTA_LOW_TOTAL
  MEMINFO_DELTA_LOW_USED
  MEMINFO_DELTA_MAPPED
  MEMINFO_DELTA_MAP_COPY
  MEMINFO_DELTA_NFS_UNSTABLE
  MEMINFO_DELTA_PAGE_TABLES
  MEMINFO_DELTA_PAGE_TABLES_SEC
  MEMINFO_DELTA_PER_CPU
  MEMINFO_DELTA_SHADOWCALLSTACK
  MEMINFO_DELTA_SHARED
  MEMINFO_DELTA_SHMEM_HUGE
  MEMINFO_DELTA_SHMEM_HUGE_MAP
  MEMINFO_DELTA_SLAB
  MEMINFO_DELTA_SLAB_RECLAIM
  MEMINFO_DELTA_SLAB_UNRECLAIM
  MEMINFO_DELTA_TOTAL
  MEMINFO_DELTA_UNACCEPTED
  MEMINFO_DELTA_UNEVICTABLE
  MEMINFO_DELTA_USED
  MEMINFO_DELTA_VM_ALLOC_CHUNK
  MEMINFO_DELTA_VM_ALLOC_TOTAL
  MEMINFO_DELTA_VM_ALLOC_USED
  MEMINFO_DELTA_WRITEBACK
  MEMINFO_DELTA_WRITEBACK_TMP
  MEMINFO_DELTA_ZSWAP
  MEMINFO_DELTA_ZSWAPPED
  MEMINFO_SWAP_CACHED
  MEMINFO_SWAP_FREE
  MEMINFO_SWAP_TOTAL
  MEMINFO_SWAP_USED
  MEMINFO_SWAP_DELTA_CACHED
  MEMINFO_SWAP_DELTA_FREE
  MEMINFO_SWAP_DELTA_TOTAL
  MEMINFO_SWAP_DELTA_USED

type
  INNER_C_UNION_c_0* {.
    importc: "no_name", header: "<libproc2/meminfo.h>", bycopy, union
  .} = object
    sInt* {.importc: "s_int".}: cint
    ulInt* {.importc: "ul_int".}: culong

  MeminfoResult* {.
    importc: "struct meminfo_result", header: "<libproc2/meminfo.h>", bycopy
  .} = object
    item* {.importc: "item".}: MeminfoItem
    result* {.importc: "result".}: INNER_C_UNION_c_0

  MeminfoStack* {.
    importc: "struct meminfo_stack", header: "<libproc2/meminfo.h>", bycopy
  .} = object
    head* {.importc: "head".}: ptr MeminfoResult

  MeminfoInfo* {.
    importc: "struct meminfo_info", header: "<libproc2/meminfo.h>", bycopy
  .} = object

proc procpsMeminfoNew*(
  info: ptr ptr MeminfoInfo
): cint {.importc: "procps_meminfo_new", header: "<libproc2/meminfo.h>".}

proc procpsMeminfoRef*(
  info: ptr MeminfoInfo
): cint {.importc: "procps_meminfo_ref", header: "<libproc2/meminfo.h>".}

proc procpsMeminfoUnref*(
  info: ptr ptr MeminfoInfo
): cint {.importc: "procps_meminfo_unref", header: "<libproc2/meminfo.h>".}

proc procpsMeminfoGet*(
  info: ptr MeminfoInfo, item: MeminfoItem
): ptr MeminfoResult {.importc: "procps_meminfo_get", header: "<libproc2/meminfo.h>".}

proc procpsMeminfoSelect*(
  info: ptr MeminfoInfo, items: ptr MeminfoItem, numitems: cint
): ptr MeminfoStack {.importc: "procps_meminfo_select", header: "<libproc2/meminfo.h>".}
