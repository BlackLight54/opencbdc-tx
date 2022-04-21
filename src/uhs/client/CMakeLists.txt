project(client)
add_subdirectory(JmeterCustomSampler)

add_library(client atomizer_client.cpp
                   client.cpp
                   twophase_client.cpp)
target_include_directories(client PUBLIC ${CMAKE_CURRENT_LIST_DIR})
add_executable(client-cli client-cli.cpp)
target_link_libraries(client-cli client
                                 atomizer
                                 bech32
                                 atomizer
                                 watchtower
                                 sentinel
                                 sentinel_interface
                                 transaction
                                 locking_shard
                                 coordinator
                                 rpc
                                 network
                                 common
                                 serialization
                                 crypto
                                 secp256k1
                                 ${NURAFT_LIBRARY}
                                 ${CMAKE_THREAD_LIBS_INIT})
